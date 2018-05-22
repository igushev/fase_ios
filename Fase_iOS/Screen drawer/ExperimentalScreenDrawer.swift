//
//  ReviewedScreenDrawer.swift
//  Fase_iOS
//
//  Created by Alexey Bidnyk on 5/18/18.
//  Copyright © 2018 Fase. All rights reserved.
//

import UIKit
import SnapKit


class ExperimentalScreenDrawer {

    var view: UIView!
    private(set) var elements: Array<Element>!
    private(set) var uiControls: Array<UIView>!
    
    private var y: CGFloat
    private var maxWidth: CGFloat
    
    weak var viewModel: FaseViewModel?
    
    
    // MARK: - Init
    
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
            
            scrollView.snp.makeConstraints({ make in
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.bottom.equalToSuperview().offset(49)
                make.top.equalToSuperview().offset(64)
            })
            
            self.view.scrollView = scrollView
            scrollView.layoutIfNeeded()
        }
        
        var parentElementId = viewModel?.screen.scrollable == true ? FaseElementsId.scrollView.rawValue : nil
        
        // Draw substrate if needed
        if let tuple = elements.first {
            let element = tuple[1] as! Element
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            let height = self.scrollableContentHeight(elements: elements)
            
            if elementType == ElementType.frame, self.viewModel?.screen.scrollable == true {
                self.drawSubstrateView(id: FaseElementsId.substrateView.rawValue, superview: self.view.scrollView, height: height)
            }
            
            parentElementId = FaseElementsId.substrateView.rawValue
        }
        
        
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
    
    private func draw(element: Element, with id: String, parentElementId: String?) {
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
            break
            
        case .dateTimePicker:
            self.drawDatePicker(for: element as! DateTimePicker, with: id, parentElementId: parentElementId)
            break
            
        case .placePicker:
            self.drawPlacePicker(for: element as! PlacePicker, with: id, parentElementId: parentElementId)
            break
            
        case .select:
            self.drawSelect(for: element as! Select, with: id, parentElementId: parentElementId)
            break
            
        case .contactPicker:
            self.drawContactPicker(for: element as! ContactPicker, with: id, parentElementId: parentElementId)
            break
            
        case .switchElement:
            self.drawSwitch(for: element as! Switch, with: id, parentElementId: parentElementId)
            
        default:
            break
        }
        
        // TODO: Add gesture recognizer if at least one textfield
    }
    
    // Draw concrete elements
    
    private func drawTabBar(for element: ElementContainer, with id: String) {
        if let viewModel = self.viewModel /*viewModel.screen.scrollable == true*/ {
            var x: CGFloat = 0
            var y = self.view.frame.height - UIElementsHeight.navigation.rawValue
            let width = self.view.frame.width
            let height = UIElementsHeight.navigation.rawValue
            
            let tabBarView = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
            tabBarView.backgroundColor = UIColor.FaseColors.tabBarBackgroundColor
            tabBarView.tag = -1
            
            let navigationElemenrId: String? = element.navigationElementId
            tabBarView.faseElementId = navigationElemenrId
            let tabBarItemsCount = viewModel.screen.navigationElementButtonsCount()
            
            if let navButtons = viewModel.screen.navigationElementButtons(), tabBarItemsCount > 0 {
                x = 0
                y = 0
                let width: CGFloat = self.view.bounds.width / CGFloat(tabBarItemsCount)
                
                for button in navButtons {
                    var image: UIImage? = UIImage()
                    if let imageElement = button.imageElement(), let data = ResourcesService.getResource(by: imageElement.fileName), let savedImage = UIImage(data: data), let resizedImage = savedImage.resizedImage(with: CGSize(width: FaseImageWidth.tabBarItem.rawValue, height: FaseImageWidth.tabBarItem.rawValue)) {
                        image = resizedImage
                    }
                    
                    let uiButton = UIButton(frame: CGRect(x: x, y: y, width: width, height: UIElementsHeight.navigation.rawValue))
                    uiButton.faseElementId = button.faseElementId
                    uiButton.navigationElementId = navigationElemenrId
                    uiButton.setTitle(button.text, for: .normal)
                    uiButton.setImage(image, for: .normal)
                    uiButton.backgroundColor = UIColor.clear
                    uiButton.titleLabel?.font = uiButton.titleLabel?.font.withSize(10)
                    uiButton.setTitleColor(UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1.0), for: .normal)
                    uiButton.titleLabel?.contentMode = .left
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
        
        width = Int(superview.frame.width)
        
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
        
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.axis = (element.orientation == FrameType.horizontal) ? .horizontal : .vertical
        stackView.distribution = .fill
        stackView.faseElementId = id
        element.faseElementId = id
        
        if element.border == true {
            stackView.layer.borderWidth = 1
            stackView.layer.borderColor = UIColor.FaseColors.borderColor.cgColor
        }
        
        if element.onClick != nil {
            stackView.isUserInteractionEnabled = true
            stackView.enableUserInteractionForSuperviews()
        } else {
            stackView.isUserInteractionEnabled = false
        }
        
        // Constraints
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(stackView)
        } else {
            superview.addSubview(frame)
        }
        self.uiControls.append(frame)
        
        // Draw nested into frame elements
        self.y = (superview == self.view) ? 70 : frame.frame.minY
        for tuple in element.idElementList {
            let elementId = tuple[0] as! String
            let element = tuple[1] as! Element
            
            self.elements.append(element)
            self.draw(element: element, with: elementId, parentElementId: id)
        }
    }
    
    private func drawTextField(for element: Text, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
        }
        
        let x = self.getXForElement(with: self.maxWidth)
        let y = self.y
        let width = self.maxWidth
        let height = UIElementsHeight.textField.rawValue
        
        let frame = CGRect(x: x, y: y, width: width, height: height)
        let textField = UITextField(frame: frame)
        textField.backgroundColor = UIColor.FaseColors.textFieldBackgroundColor
        textField.textColor = UIColor.FaseColors.textColor
        textField.borderStyle = .roundedRect
        textField.faseElementId = id
        if let parentId = parentElementId {
            textField.navigationElementId = parentId
        }
                
        (superview as! UIStackView).addArrangedSubview(textField)
        self.y += textField.frame.size.height
        
        if let placeholder = element.hint {
            textField.placeholder = placeholder
        }
        
        if let text = element.text {
            textField.text = text
        }
        
        textField.enableUserInteractionForSuperviews()
        
        self.uiControls.append(textField)
        
        // Constraints
        textField.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    private func drawTextView(for element: Text, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
        }
        
        let x = self.getXForElement(with: self.maxWidth)
        let y = self.y
        let width = self.maxWidth
        let height = UIElementsHeight.textView.rawValue
        
        let frame = CGRect(x: x, y: y, width: width, height: height)
        let textView = UITextView(frame: frame)
        textView.backgroundColor = UIColor.FaseColors.textFieldBackgroundColor
        textView.textColor = UIColor.FaseColors.textColor
        textView.layer.cornerRadius = 5.0
        textView.isSelectable = true
        textView.font = UIFont.systemFont(ofSize: 17.0)
        textView.delegate = self.viewModel
        textView.faseElementId = id
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.FaseColors.borderColor.cgColor
        
        if let parentId = parentElementId {
            textView.navigationElementId = parentId
        }
        
        superview.addSubview(textView)
        self.y += textView.frame.size.height
        
        if let placeholder = element.hint, element.text == nil {
            textView.text = placeholder
            textView.textColor = UIColor.FaseColors.placeholderColor
        }
        
        if let text = element.text {
            textView.text = text
        }
        
        textView.enableUserInteractionForSuperviews()
        
        self.uiControls.append(textView)
        
        // Constraints
        textView.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    // MARK: - Utils
    
    private func drawSubstrateView(id: String, superview: UIScrollView?, height: Int) {
        if let scrollView = superview {
            let x = 0
            let y = 0
            let width = Int(scrollView.frame.width)
            
            let frame = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
            frame.faseElementId = id
            frame.isUserInteractionEnabled = true
            frame.tag = -2
            
            superview?.addSubview(frame)
            self.uiControls.append(frame)
            
            // Constraints
            frame.translatesAutoresizingMaskIntoConstraints = false
            
            frame.snp.makeConstraints { (make) in
                frame.snp.remakeConstraints({ newMake in
                    make.top.equalToSuperview()
                    make.bottom.equalToSuperview()
                    make.leading.equalToSuperview()
                    make.trailing.equalToSuperview()
                    
                    make.width.equalToSuperview()
                    make.height.equalTo(frame.frame.height)
                })
            }
            
        }
    }
    
    private func scrollableContentHeight(elements: [ElementTuple]) -> Int {
        var height: CGFloat = 0
        
        for tuple in elements {
            if tuple.count == 1 {
                break
            }
            
            let element = tuple[1] as! Element
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            if elementType == ElementType.frame {
                height += (element as! Frame).frameTotalHeight()
            }
        }
        return Int(height)
    }
    
    func view(with faseElementId: String) -> UIView? {
        for control in self.uiControls {
            if control.faseElementId == faseElementId {
                return control
            }
        }
        
        return nil
    }
    
    func viewThatIdContains(id: String) -> UIView? {
        for control in self.uiControls {
            if control.faseElementId.contains(id) == true {
                return control
            }
        }
        
        return nil
    }
    
}

