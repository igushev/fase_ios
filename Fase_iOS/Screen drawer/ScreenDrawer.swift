//
//  ScreenDrawer.swift
//  Fase_iOS
//
//  Created by Aleksey on 3/11/18.
//  Copyright © 2018 Fase. All rights reserved.
//

import UIKit
import SnapKit

enum UIElementsWidth: CGFloat {
    case textField = 110
    case button = 100
    case label = 120
    case navigation = 49
    case frame = 1000
    case image = 32
}

enum FaseElementsId: String {
    case mainButton = "main_button"
    case previousButton = "prev_step_button"
    case nextButton = "next_step_button"
    case contextMenu = "context_menu"
    case scrollView = "scrollview"
}

class ScreenDrawer {
    
    var view: UIView!
    private(set) var elements: Array<Element>!
    private(set) var uiControls: Array<UIView>!
    private var y: CGFloat
    private var maxWidth: CGFloat
    
    // TODO: - mind how do better
    weak var viewModel: FaseViewModel?
    
    
    init(with view: UIView) {
        print("Screen drawer init")
        
        self.view = view
        self.elements = []
        self.uiControls = []
        self.y = 20 + 44 // 20 - status bar height, 44 - nav bar height
        self.maxWidth = view.bounds.width - 8 * 2
    }
    
    // MARK: - Draw functions
    
    func draw(elements: Array<ElementTuple>) {
        if let viewModel = self.viewModel, viewModel.screen.scrollable == true {
            let scrollView = UIScrollView(frame: self.view.frame)
            scrollView.isScrollEnabled = true
            scrollView.showsVerticalScrollIndicator = true
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.isUserInteractionEnabled = true
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.faseElementId = "scrollview"
            
            self.view.addSubview(scrollView)
            
            // Constraints
            let views = ["scroll": scrollView];
            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[scroll]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
            let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-64-[scroll]-49-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
            
            self.view.addConstraints(horizontalConstraints)
            self.view.addConstraints(verticalConstraints)
            scrollView.layoutIfNeeded()
            
            self.view.scrollView = scrollView
        }
        
        let parentElementId = viewModel?.screen.scrollable == true ? FaseElementsId.scrollView.rawValue : nil
        
        for tuple in elements {
            if tuple.count == 1 {
                break
            }
            
            let id = tuple[0] as! String
            let element = tuple[1] as! Element
            
            self.elements.append(element)
            self.draw(element: element, with: id, parentElementId: parentElementId)
        }
        
        print("Finished drawing")
        
    }
    
    // MARK: - Private
    
    func draw(element: Element, with id: String, parentElementId: String?) {
        let elementTypeString = element.`class`
        let elementType = ElementType(with: elementTypeString)
        
        switch elementType {
            
        case .navigation:
            self.drawTabBar(for: element as! ElementContainer, with: id)
            break
            
        case .frame:
            self.drawFrame(for: element as! Frame, with: id, parentElementId: parentElementId)
            break
            
        case .text:
            if (element as! Text).multiline == true {
                self.drawTextView(for: element as! Text, with: id, parentElementId: parentElementId)
            } else {
                self.drawTextField(for: element as! Text, with: id, parentElementId: parentElementId)
            }
            break
            
        case .button:
            self.drawButton(for: element as! Button, with: id, parentElementId: parentElementId)
            break
            
        case .label:
            self.drawLabel(for: element as! Label, with: id, parentElementId: parentElementId)
            break
            
        case .image:
            self.drawImageView(for: element as! Image, with: id, parentElementId: parentElementId)
            
        default:
            break
        }
        
        // TODO: Add gesture recognizer if at least one textfield
    }
    
    func drawTabBar(for element: ElementContainer, with id: String) {
        if let viewModel = self.viewModel, viewModel.screen.scrollable == true {
            var x: CGFloat = 0
            var y = self.view.frame.height - UIElementsWidth.navigation.rawValue
            let width = self.view.frame.width
            
            let tabBarView = UIView(frame: CGRect(x: x, y: y, width: width, height: UIElementsWidth.navigation.rawValue))
            tabBarView.backgroundColor = UIColor(red: 198/256, green: 198/256, blue: 198/256, alpha: 1.0)
            tabBarView.tag = -1
            
            let navigationElemenrId: String? = element.navigationElementId
            let tabBarItemsCount = viewModel.screen.navigationElementButtonsCount()
            
            if let navButtons = viewModel.screen.navigationElementButtons(), tabBarItemsCount > 0 {
                x = 0
                y = 0
                let width: CGFloat = self.view.bounds.width / CGFloat(tabBarItemsCount)
                
                for button in navButtons {
                    var image: UIImage? = UIImage()
                    if let imageElement = button.imageElement(), let savedImage = ResourcesService.getImage(by: imageElement.fileName) {
                        image = savedImage
                    }
                    
                    let uiButton = UIButton(frame: CGRect(x: x, y: y, width: width, height: UIElementsWidth.navigation.rawValue))
                    uiButton.faseElementId = button.faseElementId
                    uiButton.navigationElementId = navigationElemenrId
                    uiButton.setTitle(button.text, for: .normal)
                    uiButton.setImage(image, for: .normal)
                    uiButton.backgroundColor = UIColor.clear
                    uiButton.titleLabel?.font = uiButton.titleLabel?.font.withSize(10)
                    uiButton.setTitleColor(UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1.0), for: .normal)
                    uiButton.centerVertically(padding: 6.0)
                    uiButton.addTarget(self.viewModel, action: #selector(FaseViewModel.onClick(_:)), for: .touchUpInside)
                    
                    tabBarView.addSubview(uiButton)
                    
                    x += width
                    
                    self.uiControls.append(uiButton)
                }
            }
            self.view.addSubview(tabBarView)
        }
    }
    
    func drawFrame(for element: Frame, with id: String, parentElementId: String?) {
        if element.idElementList.count == 0 {
            return
        }
        
        let x = 0
        var y = 0
        var width = 0
        let height = element.frameTotalHeight()
        
        var superview: UIView! = self.view
        
        if parentElementId == FaseElementsId.scrollView.rawValue {
            superview = self.view.scrollView
        }
        
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
            width = Int(superview.frame.width)
        }
        
        if superview != self.view, superview.subviews.count > 0 {
            y = Int((superview.subviews.last?.frame.maxY)!) + 1
        }
        
        
        let frame = UIView(frame: CGRect(x: x, y: y, width: width, height: Int(height)))        
        frame.faseElementId = id
        
        if element.border == true {
            frame.layer.borderWidth = 1
            frame.layer.borderColor = UIColor.white.cgColor
        }
        
        superview.addSubview(frame)
        self.uiControls.append(frame)
        
        
        // Constraints
        frame.translatesAutoresizingMaskIntoConstraints = false
        
        frame.snp.makeConstraints { (make) in
            if superview is UIScrollView {
                frame.snp.remakeConstraints({ newMake in
                    make.top.equalToSuperview()
                    make.bottom.equalToSuperview()
                    make.leading.equalToSuperview()
                    make.trailing.equalToSuperview()
                    
                    make.width.equalToSuperview()
                    make.height.equalTo(frame.frame.height)
                })
            } else {
                make.centerX.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                
                
                if superview.subviews.count > 1 {
                    let prevSubview = superview.subviews[superview.subviews.count - 2]
                    
                    if prevSubview.tag == -1 {
                        make.top.equalToSuperview().offset(64)
                        make.bottom.equalTo(prevSubview.snp.top)
                    } else {
                        make.top.equalTo(prevSubview.snp.bottom).offset(1)
                        make.height.equalTo(frame.frame.height)
                    }
                    
                } else {
                    if superview.tag == 100 {
                        make.top.equalToSuperview().offset(64)
                    } else {
                        make.top.equalToSuperview()
                    }
                    
                    if superview is UIScrollView {
                        make.centerY.equalToSuperview()
                        make.bottom.equalToSuperview()
                    }
                    
                    if superview is UIScrollView {
                        frame.snp.remakeConstraints({ newMake in
                            make.top.equalToSuperview()
                            make.bottom.equalToSuperview()
                            make.leading.equalToSuperview()
                            make.trailing.equalToSuperview()
                            
                            make.width.equalToSuperview()
                            make.height.equalTo(frame.frame.height)
                        })
                    }
                    
                    make.width.equalToSuperview()
                    make.height.equalTo(frame.frame.height)
                }
            }
        }
        
        // Draw nested into frame elements
        self.y = (superview == self.view) ? 70 : frame.frame.minY
        for tuple in element.idElementList {
            let elementId = tuple[0] as! String
            let element = tuple[1] as! Element
            
            self.elements.append(element)
            self.draw(element: element, with: elementId, parentElementId: id)
        }
    }
    
    func drawTextField(for element: Text, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
        }
        
        let x = self.getXForElement(with: self.maxWidth)
        let y = self.y
        
        let frame = CGRect(x: x, y: y, width: self.maxWidth, height: 30)
        let textField = UITextField(frame: frame)
        textField.backgroundColor = UIColor.white
        textField.borderStyle = .roundedRect
        textField.faseElementId = id
        if let parentId = parentElementId {
            textField.navigationElementId = parentId
        }
        
        superview.addSubview(textField)
        self.y += textField.frame.size.height
        
        if let placeholder = element.hint {
            textField.placeholder = placeholder
        }
        
        if let text = element.text {
            textField.text = text
        }
        
        self.uiControls.append(textField)
        
        // Constraints
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        textField.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(textField.frame.width)
            
            if superview.subviews.count > 1 {
                let prevSubview = superview.subviews[superview.subviews.count - 2]
                
                make.top.equalTo(prevSubview.snp.bottom).offset(5)
            } else {
                make.top.equalToSuperview().offset(5)
            }
        }
    }
    
    func drawTextView(for element: Text, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
        }
        
        let x = self.getXForElement(with: self.maxWidth)
        let y = self.y
        
        let frame = CGRect(x: x, y: y, width: self.maxWidth, height: 100)
        let textView = UITextView(frame: frame)
        textView.backgroundColor = UIColor.white
        textView.layer.cornerRadius = 5.0
        textView.isSelectable = true
        textView.font = UIFont.systemFont(ofSize: 17.0)
        textView.delegate = self.viewModel
        textView.faseElementId = id
        if let parentId = parentElementId {
            textView.navigationElementId = parentId
        }
        
        superview.addSubview(textView)
        self.y += textView.frame.size.height
        
        if let placeholder = element.hint {
            textView.text = placeholder
            textView.textColor = UIColor.lightGray
        }
        
        if let text = element.text {
            textView.text = text
        }
        
        self.uiControls.append(textView)
        
        // Constraints
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(textView.frame.height)
            make.width.equalTo(textView.frame.width)
            
            if superview.subviews.count > 1 {
                let prevSubview = superview.subviews[superview.subviews.count - 2]
                
                make.top.equalTo(prevSubview.snp.bottom).offset(5)
            } else {
                make.top.equalToSuperview().offset(5)
            }
        }
    }
    
    func drawButton(for element: Button, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
        }
        
        // If navigation buttons, break because they was drawn before
        if id == FaseElementsId.mainButton.rawValue || id == FaseElementsId.previousButton.rawValue || id == FaseElementsId.nextButton.rawValue {
            return
        }
        let x = self.getXForElement(with: UIElementsWidth.button.rawValue)
        let y = self.y
        
        let frame = CGRect(x: x, y: 0, width: UIElementsWidth.button.rawValue, height: 30)
        let button = UIButton(frame: frame)
        button.faseElementId = id
        
        if let parentId = parentElementId {
            button.navigationElementId = parentId
        }
        if let viewModel = self.viewModel {
            button.addTarget(viewModel, action: #selector(FaseViewModel.onClick(_:)), for: .touchUpInside)
        }
        
        superview.addSubview(button)
        self.y += button.frame.size.height
        
        if let text = element.text {
            button.setTitle(text, for: .normal)
        }
        
        self.uiControls.append(button)
        
        // Constraints
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            
            if superview.subviews.count > 1 {
                let prevSubview = superview.subviews[superview.subviews.count - 2]
                
                make.top.equalTo(prevSubview.snp.bottom).offset(5)
            } else {
                make.top.equalToSuperview().offset(5)
            }
        }
    }
    
    func drawLabel(for element: Label, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        if let parentId = parentElementId, let parentView = self.viewThatCanHasClonesWithSameId(with: parentId) {
            superview = parentView
        }
        
        let x: CGFloat = 0 //self.getXForElement(with: UIElementsWidth.button.rawValue)
        var y: CGFloat = self.y
        var width: CGFloat = self.viewSize().width
        let height: CGFloat = 30.0
        
        width = superview.bounds.width
        
        if superview != self.view, superview.subviews.count > 0 {
            y = (superview.subviews.last?.frame.maxY)! + 1
        }
        
        let frame = CGRect(x: x, y: 0, width: width, height: height)
        let label = UILabel(frame: frame)
        label.font = UIFont.systemFont(ofSize: element.font.appFontSize)
        label.faseElementId = id
        
        switch element.alight {
        case .left:
            label.textAlignment = .left
            break
            
        case .right:
            label.textAlignment = .right
            break
            
        case .center:
            label.textAlignment = .center
            break
            
        default:
            label.textAlignment = .left
        }
        
        superview.addSubview(label)
        self.y += label.frame.size.height
        
        if let text = element.text {
            label.text = text
        }
        
        self.uiControls.append(label)
        
        // Constraints
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
            
            if superview.subviews.count > 1 {
                let prevSubview = superview.subviews[superview.subviews.count - 2]
                make.top.equalTo(prevSubview.snp.bottom).offset(5)
            } else {
                // Send label in frame to avoid this check
                if superview.tag == 100 {
                    make.top.equalToSuperview().offset(70)
                } else {
                    make.top.equalToSuperview().offset(5)
                }
            }
        }
    }
    
    func drawImageView(for element: Image, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        if let parentId = parentElementId, let parentView = self.viewThatCanHasClonesWithSameId(with: parentId) {
            superview = parentView
        }
        
        let x: CGFloat = superview.frame.maxX - UIElementsWidth.image.rawValue //self.getXForElement(with: UIElementsWidth.button.rawValue)
        var y: CGFloat = self.y
        var width: CGFloat = UIElementsWidth.image.rawValue
        let height: CGFloat = UIElementsWidth.image.rawValue
        
        width = superview.bounds.width
        
        if superview != self.view, superview.subviews.count > 0 {
            y = (superview.subviews.last?.frame.maxY)! + 1
        }
        
        let frame = CGRect(x: x, y: 0, width: width, height: height)
        let imageView = UIImageView(frame: frame)
        imageView.faseElementId = id  // is it needed in label?
        imageView.contentMode = .scaleAspectFit
        
        var image: UIImage? = UIImage()
        if let savedImage = ResourcesService.getImage(by: element.fileName) {
            image = savedImage
        }
        imageView.image = image
        
        superview.addSubview(imageView)
        self.y += imageView.frame.size.height
        
        self.uiControls.append(imageView)
        
        // Constraints
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-5)
            make.top.equalToSuperview().offset(5)
            make.width.equalTo(UIElementsWidth.image.rawValue)
            make.height.equalTo(UIElementsWidth.image.rawValue)
        }
    }
    
    
    func getXForElement(with width: CGFloat) -> CGFloat {
        return self.viewSize().width / 2 - CGFloat(width / 2)
    }
    
    func viewSize() -> CGSize {
        return self.view.bounds.size
    }
    
    // MARK: - Private
    
    func view(with faseElementId: String) -> UIView? {
        for control in self.uiControls {
            if control.faseElementId == faseElementId {
                return control
            }
        }
        
        return nil
    }
    
    func viewThatCanHasClonesWithSameId(with faseElementId: String) -> UIView? {
        var elements: Array<UIView> = []
        
        for control in self.uiControls {
            if control.faseElementId == faseElementId {
                elements.append(control)
            }
        }
        
        return elements.last
    }
    
}


