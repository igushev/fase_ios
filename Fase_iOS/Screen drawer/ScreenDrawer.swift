//
//  ScreenDrawer.swift
//  Fase_iOS
//
//  Created by Aleksey on 3/11/18.
//  Copyright © 2018 Fase. All rights reserved.
//

import UIKit

enum UIElementsWidth: CGFloat {
    case textField = 110
    case button = 100
    case label = 120
    case navigation = 49
    case frame = 1000
}

enum FaseElementsId: String {
    case mainButton = "main_button"
    case previousButton = "prev_step_button"
    case nextButton = "next_step_button"
    case contextMenu = "context_menu"
}

class ScreenDrawer {
    
    var view: UIView!
    private(set) var elements: Array<Element>!
    private(set) var uiControls: Array<UIView>!
    private var y: CGFloat
    private var maxWidth: CGFloat
    
    // TODO: - mind how do better
    weak var viewModel: FaseViewModel!
    
    
    init(with view: UIView) {
        print("Screen drawer init")
        
        self.view = view
        self.elements = []
        self.uiControls = []
        self.y = 20 // 20 - status bar height
        self.maxWidth = view.bounds.width - 8 * 2
    }
    
    // MARK: - Draw functions
    
    func draw(elements: Array<ElementTuple>) {
        if self.viewModel.screen.scrollable == true {
            let scrollView = UIScrollView(frame: self.view.frame)
            scrollView.isScrollEnabled = true
            scrollView.showsVerticalScrollIndicator = true
            scrollView.showsHorizontalScrollIndicator = false
            //            scrollView.backgroundColor = UIColor.brown
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            
            self.view.addSubview(scrollView)
            
            // Constraints
            let views = ["scroll": scrollView];
            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[scroll]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
            let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-64-[scroll]-49-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
            
            self.view.addConstraints(horizontalConstraints)
            self.view.addConstraints(verticalConstraints)
            scrollView.layoutIfNeeded()
        }
        
        for tuple in elements {
            if tuple.count == 1 {
                break
            }
            
            let id = tuple[0] as! String
            let element = tuple[1] as! Element
            
            self.elements.append(element)
            self.draw(element: element, with: id, parentElementId: nil)
        }
        
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
            self.drawFrame(for: element as! Frame, with: id)
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
            self.drawLabel(for: element as! Label, with: id)
            break
            
        default:
            break
        }
        
        // TODO: Add gesture recognizer if at least one textfield
    }
    
    func drawTabBar(for element: ElementContainer, with id: String) {
        if self.viewModel.isNeedTabBar == true {
            var x: CGFloat = 0
            var y = self.view.frame.height - UIElementsWidth.navigation.rawValue
            let width = self.view.frame.width
            
            let tabBarView = UIView(frame: CGRect(x: x, y: y, width: width, height: UIElementsWidth.navigation.rawValue))
            tabBarView.backgroundColor = UIColor(red: 198/256, green: 198/256, blue: 198/256, alpha: 1.0)
            
            let navigationElemenrId: String? = element.navigationElementId
            let tabBarItemsCount = self.viewModel.screen.navigationElementButtonsCount()
            
            if let navButtons = self.viewModel.screen.navigationElementButtons(), tabBarItemsCount > 0 {
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
    
    // TODO: If elements are nested into frame, add them as subview to it
    func drawFrame(for element: Frame, with id: String) {
        if element.idElementList.count == 0 {
            return
        }
        
        let x = 0
        let y = 0
        
        let frame = UIView(frame: CGRect(x: x, y: y, width: 0, height: 0))
        frame.faseElementId = id
        //        frame.backgroundColor = UIColor.red
        frame.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(frame)
        self.uiControls.append(frame)
        
        // Constraints
        let views = ["frame": frame];
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[frame]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-64-[frame]-49-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        self.view.addConstraints(horizontalConstraints)
        self.view.addConstraints(verticalConstraints)
        frame.layoutIfNeeded()
        
        // Draw nested into frame elements
        self.y = 70
        for tuple in element.idElementList {
            let elementId = tuple[0] as! String
            let element = tuple[1] as! Element
            
            self.elements.append(element)
            self.draw(element: element, with: elementId, parentElementId: id)
        }
    }
    
    func drawTextField(for element: Text, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
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
        
        self.view.addSubview(textField)
        self.y += textField.frame.size.height
        
        if let placeholder = element.hint {
            textField.placeholder = placeholder
        }
        
        if let text = element.text {
            textField.text = text
        }
        
        self.uiControls.append(textField)
    }
    
    func drawTextView(for element: Text, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
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
        
        self.view.addSubview(textView)
        self.y += textView.frame.size.height
        
        if let placeholder = element.hint {
            textView.text = placeholder
            textView.textColor = UIColor.lightGray
        }
        
        if let text = element.text {
            textView.text = text
        }
        
        self.uiControls.append(textView)
    }
    
    func drawButton(for element: Button, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        // If navigation buttons, break because they was drawn before
        if id == FaseElementsId.mainButton.rawValue || id == FaseElementsId.previousButton.rawValue || id == FaseElementsId.nextButton.rawValue {
            return
        }
        let x = self.getXForElement(with: UIElementsWidth.button.rawValue)
        let y = self.y
        
        let frame = CGRect(x: x, y: y, width: UIElementsWidth.button.rawValue, height: 30)
        let button = UIButton(frame: frame)
        button.faseElementId = id
        
        if let parentId = parentElementId {
            button.navigationElementId = parentId
        }
        if let viewModel = self.viewModel {
            button.addTarget(viewModel, action: #selector(FaseViewModel.onClick(_:)), for: .touchUpInside)
        }
        
        self.view.addSubview(button)
        self.y += button.frame.size.height
        
        if let text = element.text {
            button.setTitle(text, for: .normal)
        }
        
        self.uiControls.append(button)
    }
    
    func drawLabel(for element: Label, with id: String) {
        element.faseElementId = id
        
        let x = self.getXForElement(with: UIElementsWidth.button.rawValue)
        let y = self.y
        
        let frame = CGRect(x: x, y: y, width: UIElementsWidth.label.rawValue, height: 30)
        let label = UILabel(frame: frame)
        label.faseElementId = id  // is it needed in label?
        
        self.view.addSubview(label)
        self.y += label.frame.size.height
        
        if let text = element.text {
            label.text = text
        }
        
        self.uiControls.append(label)
    }
    
    
    func getXForElement(with width: CGFloat) -> CGFloat {
        return self.viewSize().width / 2 - CGFloat(width / 2)
    }
    
    func viewSize() -> CGSize {
        return self.view.bounds.size
    }
}


