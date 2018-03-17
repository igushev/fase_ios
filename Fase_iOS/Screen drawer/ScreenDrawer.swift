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
    case button = 50
    case label = 120
}

class ScreenDrawer {
    
    var view: UIView!
    private(set) var elements: Array<Element>!
    private(set) var uiControls: Array<UIView>!
    private var y: CGFloat
    
    // TODO: - mind how do better
    weak var viewModel: FaseViewModel?
    
    
    init(with view: UIView) {
        print("Screen drawer init")
        
        self.view = view
        self.elements = []
        self.uiControls = []
        self.y = 20 // 20 - status bar height
    }
    
    // MARK: - Draw functions
    
    func draw(elements: Array<ElementTuple>) {
        for tuple in elements {
            let id = tuple[0] as! String
            let element = tuple[1] as! Element
            
            self.elements.append(element)
            self.draw(element: element, with: id)
            
            print("dd")
        }
        
    }
    
    // MARK: - Private
    
    func draw(element: Element, with id: String) {
        let elementTypeString = element.`class`
        let elementType = ElementType(with: elementTypeString)
        
        switch elementType {
        case .text:
            self.drawTextField(for: element as! Text, with: id)
            break
            
        case .button:
            self.drawButton(for: element as! Button, with: id)
            break
            
        case .label:
            self.drawLabel(for: element as! Label, with: id)
            break
            
        default:
            break
        }
        
        // TODO: - Add gesture recognizer if at least one textfield
    }
    
    func drawTextField(for element: Text, with id: String) {
        let x = self.getXForElement(with: UIElementsWidth.textField.rawValue)
        let y = self.y
        
        let frame = CGRect(x: x, y: y, width: UIElementsWidth.textField.rawValue, height: 30)
        let textField = UITextField(frame: frame)
        textField.backgroundColor = UIColor.white
        textField.borderStyle = .roundedRect
        textField.faseElementId = id
        
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
    
    func drawButton(for element: Button, with id: String) {
        let x = self.getXForElement(with: UIElementsWidth.button.rawValue)
        let y = self.y
        
        let frame = CGRect(x: x, y: y, width: UIElementsWidth.button.rawValue, height: 30)
        let button = UIButton(frame: frame)
        button.faseElementId = id
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
        let x = self.getXForElement(with: UIElementsWidth.button.rawValue)
        let y = self.y
        
        let frame = CGRect(x: x, y: y, width: UIElementsWidth.label.rawValue, height: 30)
        let label = UILabel(frame: frame)
        //        label.faseElementId = id  // is it needed in label?
        
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


