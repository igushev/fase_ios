//
//  ReviewedScreenDrawer.swift
//  Fase_iOS
//
//  Created by Alexey Bidnyk on 5/18/18.
//  Copyright © 2018 Fase. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

enum UIElementsWidth: CGFloat {
    case textField = 110
    case button = 100
    case label = 120
    case frame = 1000
    case image = 32
    case `switch` = 49.0
}

enum UIElementsHeight: CGFloat {
    case textField = 30.0
    case textView = 100.0
    case button = 34.0
    case label = 30.01
    case navigation = 49.0
    case verticalSpace = 5.0
    case `switch` = 31.0
    case web = 200.0
}

enum FaseElementsId: String {
    case mainButton = "main_button"
    case previousButton = "prev_step_button"
    case nextButton = "next_step_button"
    case contextMenu = "context_menu"
    case scrollView = "scrollview"
    case substrateView = "substrate_view"
    case navigation = "navigation"
}

class ScreenDrawer {
    
    var view: UIView!
    private(set) var elements: Array<Element>!
    private(set) var uiControls: Array<UIView>!
    
    weak var viewModel: FaseViewModel?
    var datePickerSetupBlock: ((UITextField) -> Void)?
    var pickerSetupBlock: ((UITextField) -> Void)?
    
    // MARK: - Init
    
    init(with view: UIView) {
        print("Screen drawer init")
        
        self.view = view
        self.elements = []
        self.uiControls = []
    }
    
    // MARK: - Draw functions
    
    func draw(elements: Array<ElementTuple>) {
        // Add ScrollView is Screen is scrollable.
        if let viewModel = self.viewModel, viewModel.screen.scrollable == true {
            let scrollView = UIScrollView(frame: self.view.frame)
            scrollView.isScrollEnabled = true
            scrollView.showsVerticalScrollIndicator = true
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.isUserInteractionEnabled = true
            
            self.view.addSubview(scrollView)
            
            scrollView.snp.makeConstraints({ make in
                make.top.equalToSuperview().offset(64)
                make.bottom.equalToSuperview()
                if viewModel.screen.hasNavigationElement() {
                    make.bottom.equalToSuperview().offset(-UIElementsHeight.navigation.rawValue)
                }
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
            })
            
            self.view.scrollView = scrollView
            scrollView.layoutIfNeeded()
        }
        
        // Add Top-Level StackView where all Elements will be added.
        // Put it either inside ScrollView or directly into View.
        // Code below would be agnistic to where StackView is located.
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.faseElementId = FaseElementsId.substrateView.rawValue
        self.uiControls.append(stackView)
        
        if let viewModel = self.viewModel, viewModel.screen.scrollable == true {
            self.view.scrollView?.addSubview(stackView)
            stackView.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
                make.trailing.equalToSuperview()
            }
        } else if self.viewModel?.screen.scrollable != true {
            self.view.addSubview(stackView)
            
            stackView.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(64)
            }
            if let viewModel = self.viewModel, viewModel.screen.hasElementWithMaxSize() == true {
                stackView.snp.makeConstraints { (make) in
                    make.bottom.equalToSuperview()
                    if viewModel.screen.hasNavigationElement() {
                        make.bottom.equalToSuperview().offset(-UIElementsHeight.navigation.rawValue)
                    }
                    make.trailing.equalToSuperview()
                }
            }
        }
        
        stackView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        var parentElementId = FaseElementsId.substrateView.rawValue
        
        for tuple in elements {
            if tuple.count == 1 {
                continue
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
            break
            
        case .separator:
            self.drawSeparator(for: element as! Separator, with: id, parentElementId: parentElementId)
            break
            
        case .slider:
            self.drawSlider(for: element as! Slider, with: id, parentElementId: parentElementId)
            break
            
        case .web:
            self.drawWeb(for: element as! Web, with: id, parentElementId: parentElementId)
            break
            
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
                    self.elements.append(button)
                }
            }
            self.view.addSubview(tabBarView)
        }
    }
    
    func drawFrame(for element: Frame, with id: String, parentElementId: String?) {
        var superview: UIView! = self.view
        
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
        }
        
        let stackView = UIStackView()
        stackView.axis = (element.orientation == FrameType.horizontal) ? .horizontal : .vertical
        stackView.distribution = .fill
        
        stackView.spacing = 2.0
        stackView.layoutMargins = UIEdgeInsetsMake(2, 2, 2, 2)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        stackView.faseElementId = id
        element.faseElementId = id
        
        if element.border == true {
            stackView.layer.borderWidth = 1
            stackView.layer.borderColor = UIColor.FaseColors.borderColor.cgColor
        }
        
        stackView.isUserInteractionEnabled = true
        if element.onClick != nil {
            stackView.enableUserInteractionForSuperviews()
            
            let tapGR = UITapGestureRecognizer(target: self.viewModel, action: #selector(FaseViewModel.onClickGestureRecognizer(_:)))
            stackView.addGestureRecognizer(tapGR)
        }
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(stackView)
        } else {
            superview.addSubview(stackView)
        }
        self.uiControls.append(stackView)
        
        // Draw nested into frame elements
        if element.idElementList.count > 0 {
            for tuple in element.idElementList {
                if tuple.count == 1 {
                    continue
                }
                
                let elementId = tuple[0] as! String
                let element = tuple[1] as! Element
                
                self.elements.append(element)
                self.draw(element: element, with: elementId, parentElementId: id)
            }
        }
        
    }
    
    private func drawTextField(for element: Text, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
        }
        
        let textField = UITextField()
        textField.backgroundColor = UIColor.FaseColors.textFieldBackgroundColor
        textField.textColor = UIColor.FaseColors.textColor
        textField.borderStyle = .roundedRect
        textField.faseElementId = id
        textField.isHidden = !element.isDisplayed
        
        let toolbar = UIToolbar()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self.viewModel, action: #selector(FaseViewModel.onDismissKeyboard))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexibleItem, doneButton]
        toolbar.barStyle = .default
        toolbar.isUserInteractionEnabled = true
        toolbar.sizeToFit()
        
        textField.inputAccessoryView = toolbar
        
        if let parentId = parentElementId {
            textField.navigationElementId = parentId
        }
        
        if let placeholder = element.hint {
            textField.placeholder = placeholder
        }
        
        if let text = element.text {
            textField.text = text
        }
        
        if let textType = element.type {
            switch textType {
            case .digits:
                textField.keyboardType = .numbersAndPunctuation
                break
                
            case .email:
                textField.keyboardType = .emailAddress
                break
                
            case .phone:
                textField.keyboardType = .phonePad
                break
                
            default:
                textField.keyboardType = .asciiCapable
                break
            }
        }
        
        let contentSize = textField.intrinsicContentSize
        textField.heightAnchor.constraint(equalToConstant: contentSize.height).isActive = true
        textField.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        textField.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(textField)
        } else {
            superview.addSubview(textField)
        }
        self.uiControls.append(textField)
        
        textField.enableUserInteractionForSuperviews()
    }
    
    private func drawTextView(for element: Text, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
        }
        
        let textView = UITextView()
        textView.backgroundColor = UIColor.FaseColors.textFieldBackgroundColor
        textView.textColor = UIColor.FaseColors.textColor
        textView.layer.cornerRadius = 5.0
        textView.isSelectable = true
        textView.font = UIFont.systemFont(ofSize: 17.0)
        textView.delegate = self.viewModel
        textView.faseElementId = id
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.FaseColors.borderColor.cgColor
        textView.isHidden = !element.isDisplayed
        
        let toolbar = UIToolbar()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self.viewModel, action: #selector(FaseViewModel.onDismissKeyboard))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexibleItem, doneButton]
        toolbar.barStyle = .default
        toolbar.isUserInteractionEnabled = true
        toolbar.sizeToFit()
        
        textView.inputAccessoryView = toolbar  
        
        if let parentId = parentElementId {
            textView.navigationElementId = parentId
        }
        
        if let placeholder = element.hint, element.text == nil || element.text == "" {
            textView.text = placeholder
            textView.textColor = UIColor.FaseColors.placeholderColor
        }
        
        if let text = element.text, text.isEmpty == false {
            textView.text = text
        }
        
        let contentSize = textView.intrinsicContentSize
        textView.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        if element.size != .min {
            textView.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .vertical)
            textView.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .vertical)
        }
        else {
            if let font = textView.font {
                textView.heightAnchor.constraint(equalToConstant: font.lineHeight * 3).isActive = true
            }
        }
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(textView)
        } else {
            superview.addSubview(textView)
        }
        self.uiControls.append(textView)
        
        textView.enableUserInteractionForSuperviews()
    }
    
    private func drawButton(for element: Button, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
        }
        
        // If navigation buttons, break because they was drawn before
        if id == FaseElementsId.mainButton.rawValue || id == FaseElementsId.previousButton.rawValue || id == FaseElementsId.nextButton.rawValue {
            return
        }
        
        let button = UIButton()
        button.setTitleColor(UIColor.FaseColors.buttonTextColor, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5.0
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.FaseColors.borderColor.cgColor
        button.faseElementId = id
        button.isHidden = !element.isDisplayed
        
        if let parentId = parentElementId {
            button.navigationElementId = parentId
        }
        if let viewModel = self.viewModel {
            button.addTarget(viewModel, action: #selector(FaseViewModel.onClick(_:)), for: .touchUpInside)
        }
        
        if let text = element.text {
            button.setTitle(text, for: .normal)
        }
        
        if let imageElement = element.imageElement() {
            if let urlString = imageElement.url, let url = URL(string: urlString), let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                button.setImage(image, for: .normal)
            }
            if let data = ResourcesService.getResource(by: imageElement.fileName), let savedImage = UIImage(data: data) {
                button.setImage(savedImage, for: .normal)
            }
            
            button.imageView?.contentMode = .scaleAspectFit
        }
        
        let contentSize = button.intrinsicContentSize
        button.heightAnchor.constraint(equalToConstant: contentSize.height).isActive = true
        button.widthAnchor.constraint(equalToConstant: contentSize.width).isActive = true
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(button)
        } else {
            superview.addSubview(button)
        }
        self.uiControls.append(button)
        button.enableUserInteractionForSuperviews()
    }
    
    private func drawLabel(for element: Label, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        
        if let parentId = parentElementId, let parentView = self.viewThatCanHasClonesWithSameId(with: parentId) {
            superview = parentView
        }
        
        let label = UILabel()
        if let font = element.font {
            label.font = UIFont.systemFont(ofSize: font.size.appFontSize)
            if font.bold {
                label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
            }
            if font.italic {
                label.font = UIFont.italicSystemFont(ofSize: label.font.pointSize)
            }
        }
        
        label.textColor = UIColor.FaseColors.textColor
        label.faseElementId = id
        label.isUserInteractionEnabled = true
        label.isHidden = !element.isDisplayed
        
        if let text = element.text {
            label.text = text
        }
        
        if element.onClick != nil {
            label.isUserInteractionEnabled = true
            label.enableUserInteractionForSuperviews()
            
            let tapGR = UITapGestureRecognizer(target: self.viewModel, action: #selector(FaseViewModel.onClickGestureRecognizer(_:)))
            label.addGestureRecognizer(tapGR)
        }
        
        if let align = element.align {
            label.textAlignment = self.textAlignmentDependOn(elementTextAlignment: align)
        }
        
        let contentSize = label.intrinsicContentSize
        label.heightAnchor.constraint(equalToConstant: contentSize.height).isActive = true
        if element.size != .min {
            label.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
            label.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        }
        else {
            label.widthAnchor.constraint(equalToConstant: contentSize.width).isActive = true
        }
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(label)
        } else {
            superview.addSubview(label)
        }
        self.uiControls.append(label)
        
    }
    
    private func drawImageView(for element: Image, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        
        if let parentId = parentElementId, let parentView = self.viewThatCanHasClonesWithSameId(with: parentId) {
            superview = parentView
        }
        
        // Get Image itself
        var image: UIImage? = UIImage()
        if let urlString = element.url, let url = URL(string: urlString), let data = try? Data(contentsOf: url), let urlImage = UIImage(data: data) {
            image = urlImage
        } else if let data = ResourcesService.getResource(by: element.fileName), let filenameImage = UIImage(data: data) {
            image = filenameImage
        }
        
        let imageView = UIImageView(image: image)
        imageView.faseElementId = id
        imageView.isUserInteractionEnabled = false
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = !element.isDisplayed
        
        if let image = imageView.image {
            imageView.widthAnchor.constraint(equalToConstant: image.size.width).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: image.size.height).isActive = true
        }
        
        if element.onClick != nil {
            imageView.isUserInteractionEnabled = true
            imageView.enableUserInteractionForSuperviews()
            
            let tapGR = UITapGestureRecognizer(target: self.viewModel, action: #selector(FaseViewModel.onClickGestureRecognizer(_:)))
            imageView.addGestureRecognizer(tapGR)
        }
        
        if let align = element.align {
            switch align {
            case .left:
                imageView.contentMode = .left
                break
                
            case .right:
                imageView.contentMode = .right
                break
                
            case .center:
                imageView.contentMode = .center
                break
                
            default:
                imageView.contentMode = .scaleAspectFit
                break
            }
        }
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(imageView)
        } else {
            superview.addSubview(imageView)
        }
        self.uiControls.append(imageView)
    }
    
    private func drawDatePicker(for element: DateTimePicker, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
        }
        
        let textField = UITextField()
        textField.faseElementId = id
        
        if let setupBlock = self.datePickerSetupBlock {
            setupBlock(textField)
        }
        
        textField.backgroundColor = UIColor.FaseColors.textFieldBackgroundColor
        textField.textColor = UIColor.FaseColors.textColor
        textField.borderStyle = .roundedRect
        textField.isHidden = !element.isDisplayed
        
        if let parentId = parentElementId {
            textField.navigationElementId = parentId
        }
        
        if let placeholder = element.hint {
            textField.placeholder = placeholder
        }
        
        if let value = element.datetime {
            textField.text = String(describing: value)
        }
        
        let contentSize = textField.intrinsicContentSize
        textField.heightAnchor.constraint(equalToConstant: contentSize.height).isActive = true
        textField.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        textField.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(textField)
        } else {
            superview.addSubview(textField)
        }
        self.uiControls.append(textField)
    }
    
    private func drawPlacePicker(for element: PlacePicker, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
        }
        
        let textField = UITextField()
        textField.backgroundColor = UIColor.FaseColors.textFieldBackgroundColor
        textField.textColor = UIColor.FaseColors.textColor
        textField.borderStyle = .roundedRect
        textField.delegate = self.viewModel
        textField.faseElementId = id
        textField.isHidden = !element.isDisplayed
        
        if let parentId = parentElementId {
            textField.navigationElementId = parentId
        }
        
        if let placeholder = element.hint {
            textField.placeholder = placeholder
        }
        
        if let place = element.place, let text = place.placeString(for: element.type) {
            textField.text = text
        }
        
        let contentSize = textField.intrinsicContentSize
        textField.heightAnchor.constraint(equalToConstant: contentSize.height).isActive = true
        textField.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        textField.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(textField)
        } else {
            superview.addSubview(textField)
        }
        self.uiControls.append(textField)
    }
    
    private func drawSelect(for element: Select, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
        }
        let textField = UITextField()
        textField.faseElementId = id
        
        
        if let setupBlock = self.pickerSetupBlock {
            setupBlock(textField)
        }
        
        textField.backgroundColor = UIColor.FaseColors.textFieldBackgroundColor
        textField.textColor = UIColor.FaseColors.textColor
        textField.borderStyle = .roundedRect
        textField.delegate = self.viewModel
        textField.textAlignment = self.textAlignmentDependOn(elementTextAlignment: element.align)
        textField.isHidden = !element.isDisplayed
        
        if let parentId = parentElementId {
            textField.navigationElementId = parentId
        }
        
        if let placeholder = element.hint {
            textField.placeholder = placeholder
        }
        
        if let text = element.value {
            textField.text = text
        }
        
        let contentSize = textField.intrinsicContentSize
        textField.heightAnchor.constraint(equalToConstant: contentSize.height).isActive = true
        textField.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        textField.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(textField)
        } else {
            superview.addSubview(textField)
        }
        self.uiControls.append(textField)
    }
    
    private func drawContactPicker(for element: ContactPicker, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
        }
        let textField = UITextField()
        textField.backgroundColor = UIColor.FaseColors.textFieldBackgroundColor
        textField.textColor = UIColor.FaseColors.textColor
        textField.borderStyle = .roundedRect
        textField.delegate = self.viewModel
        textField.faseElementId = id
        textField.isHidden = !element.isDisplayed
        
        if let parentId = parentElementId {
            textField.navigationElementId = parentId
        }
        
        if let placeholder = element.hint {
            textField.placeholder = placeholder
        }
        
        if let contact = element.contact {
            textField.text = contact.displayName
        }
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(textField)
        } else {
            superview.addSubview(textField)
        }
        self.uiControls.append(textField)
        
        let contentSize = textField.intrinsicContentSize
        textField.heightAnchor.constraint(equalToConstant: contentSize.height).isActive = true
        textField.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        textField.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
    }
    
    private func drawSwitch(for element: Switch, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
        }
        
        let switch_ = UISwitch()
        switch_.isOn = element.value
        switch_.faseElementId = id
        let contentSize = switch_.intrinsicContentSize
        switch_.heightAnchor.constraint(equalToConstant: contentSize.height).isActive = true
        switch_.widthAnchor.constraint(equalToConstant: contentSize.width).isActive = true
        switch_.isHidden = !element.isDisplayed
        
        var height = contentSize.height
        var width = contentSize.width
        
        let switchStackView = UIStackView(arrangedSubviews: [switch_])
        switchStackView.axis = .horizontal
        switchStackView.distribution = .fill
        switchStackView.spacing = 5.0
        
        if let text = element.text {
            let label = UILabel()
            label.textColor = UIColor.FaseColors.textColor
            label.faseElementId = id
            label.isUserInteractionEnabled = true
            label.text = text
            label.isHidden = !element.isDisplayed
            
            let contentSize = label.intrinsicContentSize
            label.heightAnchor.constraint(equalToConstant: contentSize.height).isActive = true
            label.widthAnchor.constraint(equalToConstant: contentSize.width).isActive = true
            height = max(height, contentSize.height)
            width += contentSize.width
            switchStackView.addArrangedSubview(label)
        }
        
        switchStackView.heightAnchor.constraint(equalToConstant: height).isActive = true
        switchStackView.widthAnchor.constraint(equalToConstant: width).isActive = true
        
        // TODO: Does not work.
        if let align = element.align {
            switch align {
            case .left:
                switchStackView.contentMode = .left
                break
                
            case .right:
                switchStackView.contentMode = .right
                break
                
            case .center:
                switchStackView.contentMode = .center
                break
            }
        } else {
            switchStackView.contentMode = .center
        }
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(switchStackView)
        } else {
            superview.addSubview(switchStackView)
        }
        self.uiControls.append(switch_)
    }
    
    private func drawSlider(for element: Slider, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
        }
        
        let slider = UISlider()
        slider.minimumValue = element.minValue
        slider.maximumValue = element.maxValue
        slider.value = element.value
        slider.addTarget(self.viewModel, action: #selector(FaseViewModel.onSliderValueChanged(_:)), for: .valueChanged)
        slider.faseElementId = id
        slider.isHidden = !element.isDisplayed
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(slider)
        } else {
            superview.addSubview(slider)
        }
        self.uiControls.append(slider)
    }
    
    private func drawSeparator(for element: Separator, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
        }
        
        let separator = UIView(frame: CGRect(x: 0, y: 0, width: superview.frame.width, height: 1.0))
        separator.backgroundColor = UIColor.gray
        separator.faseElementId = id
        separator.isHidden = !element.isDisplayed
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(separator)
        } else {
            superview.addSubview(separator)
        }
        self.uiControls.append(separator)
        
        // TODO: - Add on server frame type (vertical, horizontal) for separator
        if let stackView = separator.superview as? UIStackView {
            if stackView.axis == .vertical {
                separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
            } else {
                separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
            }
        }
        
    }
    
    private func drawWeb(for element: Web, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
        }
        
        let webView = WKWebView()
        
        webView.uiDelegate = self.viewModel
        webView.navigationDelegate = self.viewModel
        webView.contentMode = .scaleAspectFit
        webView.faseElementId = id
        webView.scrollView?.isScrollEnabled = element.scrollable
        webView.isHidden = !element.isDisplayed
        
        if let urlString = element.url, let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(webView)
        } else {
            superview.addSubview(webView)
        }
        self.uiControls.append(webView)
        
        webView.heightAnchor.constraint(equalToConstant: 300)
    }
    
    // MARK: - Utils
    
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
            if control.faseElementId?.contains(id) == true {
                return control
            }
        }
        
        return nil
    }
    
    private func getXForElement(with width: CGFloat) -> CGFloat {
        return self.viewSize().width / 2 - CGFloat(width / 2)
    }
    
    private func viewSize() -> CGSize {
        return self.view.bounds.size
    }
    
    private func datePickerInputView() -> UITextField? {
        if let textField = self.viewThatIdContains(id: "date_picker") as? UITextField {
            return textField
        }
        return nil
    }
    
    private func textAlignmentDependOn(elementTextAlignment: Align) -> NSTextAlignment {
        switch elementTextAlignment {
        case .left:
            return .left
            
        case .right:
            return .right
            
        case .center:
            return .center
            
        default:
            return .left
        }
    }
    
    // MARK: - Used for drawing duplicated frames with same id
    
    func viewThatCanHasClonesWithSameId(with faseElementId: String) -> UIView? {
        var elements: Array<UIView> = []
        
        for control in self.uiControls {
            if let controlElementId = control.faseElementId {
                if controlElementId == faseElementId {
                    elements.append(control)
                }
            }
        }
        
        return elements.last
    }
    
}

