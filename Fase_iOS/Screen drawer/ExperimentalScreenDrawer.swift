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
    var datePickerSetupBlock: ((UITextField) -> Void)?
    var pickerSetupBlock: ((UITextField) -> Void)?
    
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
                make.bottom.equalToSuperview().offset(-50) // Hack to avoid
                make.top.equalToSuperview().offset(64)
            })
            
            self.view.scrollView = scrollView
            scrollView.layoutIfNeeded()
        }
        
        var parentElementId = viewModel?.screen.scrollable == true ? FaseElementsId.scrollView.rawValue : nil
        
        // FIXME: - Correctly get frame element
        // Draw substrate if needed
        if let tuple = elements.first {
            let element = tuple[1] as! Element
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            let height = self.scrollableContentHeight(elements: elements)
            
            if elementType == ElementType.frame, self.viewModel?.screen.scrollable == true {
                self.drawSubstrateView(id: FaseElementsId.substrateView.rawValue, superview: self.view.scrollView, height: height)
            } else if self.viewModel?.screen.scrollable != true {
                let height = self.viewModel?.screen.screenContentHeight()
                self.drawStackViewSubstrateView(id: FaseElementsId.substrateView.rawValue, superview: self.view, height: height!)
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
        // Commented to allow draw empty frames with MAX size
        //        if element.idElementList.count == 0 {
        //            return
        //        }
        
        var superview: UIView! = self.view
        
        let x = 0
        var y = 0
        var width = Int(superview.frame.width)
        let height = Int(element.frameTotalHeight())
        
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
        
        if element.idElementList.count == 0 {
            let view = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
            
            if superview is UIStackView {
                (superview as! UIStackView).addArrangedSubview(view)
            } else {
                superview.addSubview(view)
            }
            
            self.uiControls.append(view)
        } else {
            let stackView = UIStackView(frame: CGRect(x: x, y: y, width: width, height: height))
            stackView.axis = (element.orientation == FrameType.horizontal) ? .horizontal : .vertical
            
            if element.orientation == FrameType.horizontal {
                stackView.distribution = .fill
            }
            
            stackView.spacing = 5.0
            stackView.layoutMargins = UIEdgeInsetsMake(5, 5, 5, 5)
            stackView.isLayoutMarginsRelativeArrangement = true
            
            stackView.faseElementId = id
            element.faseElementId = id
            
            if element.border == true {
                stackView.layer.borderWidth = 1
                stackView.layer.borderColor = UIColor.FaseColors.borderColor.cgColor
            }
            
            if element.onClick != nil {
                // TODO: - Add gesture recognizer
                stackView.isUserInteractionEnabled = true
                stackView.enableUserInteractionForSuperviews()
                
                let tapGR = UITapGestureRecognizer(target: self.viewModel, action: #selector(FaseViewModel.onClickGestureRecognizer(_:)))
                stackView.addGestureRecognizer(tapGR)
            } else {
                stackView.isUserInteractionEnabled = false
            }
            
            stackView.isUserInteractionEnabled = true
            
            if superview is UIStackView {
                (superview as! UIStackView).addArrangedSubview(stackView)
            } else {
                superview.addSubview(stackView)
            }
            self.uiControls.append(stackView)
            
            // Constraints
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.snp.makeConstraints({ make in
                
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                
                if element.orientation == FrameType.horizontal || element.size == .min {
                    make.height.equalTo(height)
                } else {
                    
                }
                
                if superview.subviews.count > 1 {
                    let prevSubview = superview.subviews[superview.subviews.count - 2]
                    
                    if prevSubview.tag == -1 {
                        make.top.equalToSuperview().offset(64)
                        //                    make.bottom.equalTo(prevSubview.snp.top)
                    } else if prevSubview.tag == -2 {
                        
                    } else {
                        make.top.equalTo(prevSubview.snp.bottom).offset(1)
                    }
                } else {
                    if superview.tag == 100 {
                        make.top.equalToSuperview().offset(64)
                        make.height.equalTo(height)
                        
                        if element.hasMaxElements() == true && element.size == .max {
                            make.bottom.equalToSuperview()
                        }
                    } else {
                        make.top.equalToSuperview()
                    }
                }
                
            })
            
            // Draw nested into frame elements
            self.y = (superview == self.view) ? 70 : stackView.frame.minY
            for tuple in element.idElementList {
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
        var superviewElement: Element?
        
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
            superviewElement = self.viewModel?.element(with: parentId)
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
        
        self.y += textField.frame.size.height
        
        if let placeholder = element.hint {
            textField.placeholder = placeholder
        }
        
        if let text = element.text {
            textField.text = text
        }
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(textField)
        } else {
            superview.addSubview(textField)
        }
        self.uiControls.append(textField)
        
        textField.enableUserInteractionForSuperviews()
        
        // Constraints
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.snp.makeConstraints { (make) in
            var superviewOrientation = FrameType.none
            
            if let superviewElement = superviewElement as? Frame {
                superviewOrientation = superviewElement.orientation
            }
            FaseConstraintsMaker.makeConstraints(make: make, elementType: ElementType.text, view: textField, in: superview, superviewOrientation: superviewOrientation)
        }
        
    }
    
    private func drawTextView(for element: Text, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        var superviewElement: Element?
        
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
            superviewElement = self.viewModel?.element(with: parentId)
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
        
        self.y += textView.frame.size.height
        
        if let placeholder = element.hint, element.text == nil || element.text == "" {
            textView.text = placeholder
            textView.textColor = UIColor.FaseColors.placeholderColor
        }
        
        if let text = element.text, text.isEmpty == false {
            textView.text = text
        }
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(textView)
        } else {
            superview.addSubview(textView)
        }
        self.uiControls.append(textView)
        
        textView.enableUserInteractionForSuperviews()
        
        // Constraints
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.snp.makeConstraints { (make) in
            if element.size == .min {
                make.height.equalTo(UIElementsHeight.textView.rawValue)
            }
            
            var superviewOrientation = FrameType.none
            
            if let superviewElement = superviewElement as? Frame {
                superviewOrientation = superviewElement.orientation
            }
            FaseConstraintsMaker.makeConstraints(make: make, elementType: ElementType.text, view: textView, in: superview, superviewOrientation: superviewOrientation)
        }
        
    }
    
    private func drawButton(for element: Button, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        var superviewElement: Element?
        
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
            superviewElement = self.viewModel?.element(with: parentId)
        }
        
        // If navigation buttons, break because they was drawn before
        if id == FaseElementsId.mainButton.rawValue || id == FaseElementsId.previousButton.rawValue || id == FaseElementsId.nextButton.rawValue {
            return
        }
        let x = self.getXForElement(with: UIElementsWidth.button.rawValue)
        let y: CGFloat = 0
        let width = UIElementsWidth.button.rawValue
        let height = UIElementsHeight.button.rawValue
        
        let frame = CGRect(x: x, y: y, width: width, height: height)
        let button = UIButton(frame: frame)
        button.setTitleColor(UIColor.FaseColors.buttonTextColor, for: .normal)
        button.faseElementId = id
        
        if let parentId = parentElementId {
            button.navigationElementId = parentId
        }
        if let viewModel = self.viewModel {
            button.addTarget(viewModel, action: #selector(FaseViewModel.onClick(_:)), for: .touchUpInside)
        }
        
        self.y += button.frame.size.height
        
        if let text = element.text {
            button.setTitle(text, for: .normal)
        }
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(button)
        } else {
            superview.addSubview(button)
        }
        self.uiControls.append(button)
        button.enableUserInteractionForSuperviews()
        
        // Constraints
        button.translatesAutoresizingMaskIntoConstraints = false
        button.snp.makeConstraints { (make) in
            var superviewOrientation = FrameType.none
            
            if let superviewElement = superviewElement as? Frame {
                superviewOrientation = superviewElement.orientation
            }
            FaseConstraintsMaker.makeConstraints(make: make, elementType: ElementType.button, view: button, in: superview, superviewOrientation: superviewOrientation)
        }
    }
    
    private func drawLabel(for element: Label, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        var superviewElement: Element?
        
        if let parentId = parentElementId, let parentView = self.viewThatCanHasClonesWithSameId(with: parentId) {
            superview = parentView
            superviewElement = self.viewModel?.element(with: parentId)
        }
        
        let x: CGFloat = 0 //self.getXForElement(with: UIElementsWidth.button.rawValue)
        var y: CGFloat = 0
        var width: CGFloat = self.viewSize().width
        let height: CGFloat = UIElementsHeight.label.rawValue
        
        width = superview.bounds.width
        
        if superview != self.view, superview.subviews.count > 0 {
            y = (superview.subviews.last?.frame.maxY)! + 1
        }
        
        let frame = CGRect(x: x, y: y, width: width, height: height)
        let label = UILabel(frame: frame)
        label.font = UIFont.systemFont(ofSize: element.font.appFontSize)
        label.textColor = UIColor.FaseColors.textColor
        label.faseElementId = id
        label.isUserInteractionEnabled = true
        
        switch element.align {
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
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(label)
        } else {
            superview.addSubview(label)
        }
        self.uiControls.append(label)
        
        // Constraints
        label.translatesAutoresizingMaskIntoConstraints = false
        label.snp.makeConstraints { (make) in
            var superviewOrientation = FrameType.none
            
            if let superviewElement = superviewElement as? Frame {
                superviewOrientation = superviewElement.orientation
            }
            
            if element.size == .min {
                let contentSize = label.intrinsicContentSize
                label.snp.makeConstraints({ make in
                    make.width.equalTo(contentSize.width)
                })
            }
            
            FaseConstraintsMaker.makeConstraints(make: make, elementType: ElementType.label, view: label, in: superview, superviewOrientation: superviewOrientation)
            
            //            if let text = label.text, text.isEmpty == false {
            //                let labelHeight = text.textHeight(with: label.font)
            //                make.height.equalTo(labelHeight)
            //            }
        }
    }
    
    private func drawImageView(for element: Image, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        var superviewElement: Element?
        
        if let parentId = parentElementId, let parentView = self.viewThatCanHasClonesWithSameId(with: parentId) {
            superview = parentView
            superviewElement = self.viewModel?.element(with: parentId)
        }
        
        let x: CGFloat = superview.frame.maxX - UIElementsWidth.image.rawValue //self.getXForElement(with: UIElementsWidth.button.rawValue)
        var y: CGFloat = 0
        let width: CGFloat = UIElementsWidth.image.rawValue
        let height: CGFloat = UIElementsWidth.image.rawValue
        
        if superview != self.view, superview.subviews.count > 0 {
            y = (superview.subviews.last?.frame.maxY)! + 1
        }
        
        let frame = CGRect(x: x, y: y, width: width, height: height)
        let imageView = UIImageView(frame: frame)
        imageView.faseElementId = id
        imageView.isUserInteractionEnabled = false
        
        if element.onClick != nil {
            imageView.isUserInteractionEnabled = true
            imageView.enableUserInteractionForSuperviews()
            
            let tapGR = UITapGestureRecognizer(target: self.viewModel, action: #selector(FaseViewModel.onClickGestureRecognizer(_:)))
            imageView.addGestureRecognizer(tapGR)
        }
        
        switch element.align {
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
            imageView.contentMode = .center
            break
        }
        
        var image: UIImage? = UIImage()
        
        if let urlString = element.url, let url = URL(string: urlString), let data = try? Data(contentsOf: url), let urlImage = UIImage(data: data) {
            //            let resizedImage = urlImage.resizedImage(with: CGSize(width: FaseImageWidth.navigationItem.rawValue, height: FaseImageWidth.navigationItem.rawValue))
            image = urlImage
        } else if let data = ResourcesService.getResource(by: element.fileName), let savedImage = UIImage(data: data) {
            //            let resizedImage = savedImage.resizedImage(with: CGSize(width: FaseImageWidth.navigationItem.rawValue, height: FaseImageWidth.navigationItem.rawValue))
            image = savedImage
        }
        imageView.image = image
        //        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        //        imageView.tintColor = UIColor.FaseColors.textColor
        
        superview.addSubview(imageView)
        self.y += imageView.frame.size.height
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(imageView)
        } else {
            superview.addSubview(imageView)
        }
        self.uiControls.append(imageView)
        
        // Constraints
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.snp.makeConstraints { make in
            //            if let image = imageView.image {
            //                make.height.equalTo(image.size.height)
            //                make.width.equalTo(image.size.width)
            //            }
        }
        
    }
    
    private func drawDatePicker(for element: DateTimePicker, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        var superviewElement: Element?
        
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
            superviewElement = self.viewModel?.element(with: parentId)
        }
        
        let x = self.getXForElement(with: self.maxWidth)
        let y = self.y
        let width = self.maxWidth
        let height = UIElementsHeight.textField.rawValue
        
        let frame = CGRect(x: x, y: y, width: width, height: height)
        let textField = UITextField(frame: frame)
        textField.faseElementId = id
        
        if let setupBlock = self.datePickerSetupBlock {
            setupBlock(textField)
        }
        
        textField.backgroundColor = UIColor.FaseColors.textFieldBackgroundColor
        textField.textColor = UIColor.FaseColors.textColor
        textField.borderStyle = .roundedRect
        if let parentId = parentElementId {
            textField.navigationElementId = parentId
        }
        
        self.y += textField.frame.size.height
        
        if let placeholder = element.hint {
            textField.placeholder = placeholder
        }
        
        if let value = element.datetime {
            textField.text = String(describing: value)
        }
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(textField)
        } else {
            superview.addSubview(textField)
        }
        self.uiControls.append(textField)
        
        // Constraints
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.snp.makeConstraints { (make) in
            var superviewOrientation = FrameType.none
            
            if let superviewElement = superviewElement as? Frame {
                superviewOrientation = superviewElement.orientation
            }
            FaseConstraintsMaker.makeConstraints(make: make, elementType: ElementType.dateTimePicker, view: textField, in: superview, superviewOrientation: superviewOrientation)
        }
        
    }
    
    private func drawPlacePicker(for element: PlacePicker, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        var superviewElement: Element?
        
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
            superviewElement = self.viewModel?.element(with: parentId)
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
        textField.delegate = self.viewModel
        textField.faseElementId = id
        if let parentId = parentElementId {
            textField.navigationElementId = parentId
        }
        
        superview.addSubview(textField)
        self.y += textField.frame.size.height
        
        if let placeholder = element.hint {
            textField.placeholder = placeholder
        }
        
        if let place = element.place, let text = place.placeString() {
            textField.text = text
        }
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(textField)
        } else {
            superview.addSubview(textField)
        }
        self.uiControls.append(textField)
        
        // Constraints
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.snp.makeConstraints { (make) in
            var superviewOrientation = FrameType.none
            
            if let superviewElement = superviewElement as? Frame {
                superviewOrientation = superviewElement.orientation
            }
            FaseConstraintsMaker.makeConstraints(make: make, elementType: ElementType.placePicker, view: textField, in: superview, superviewOrientation: superviewOrientation)
        }
        
    }
    
    private func drawSelect(for element: Select, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        var superviewElement: Element?
        
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
            superviewElement = self.viewModel?.element(with: parentId)
        }
        
        let x = self.getXForElement(with: self.maxWidth)
        let y = self.y
        let width = self.maxWidth
        let height = UIElementsHeight.textField.rawValue
        
        let frame = CGRect(x: x, y: y, width: width, height: height)
        let textField = UITextField(frame: frame)
        textField.faseElementId = id
        
        if let setupBlock = self.pickerSetupBlock {
            setupBlock(textField)
        }
        
        textField.backgroundColor = UIColor.FaseColors.textFieldBackgroundColor
        textField.textColor = UIColor.FaseColors.textColor
        textField.borderStyle = .roundedRect
        textField.delegate = self.viewModel
        
        if let parentId = parentElementId {
            textField.navigationElementId = parentId
        }
        
        self.y += textField.frame.size.height
        
        if let placeholder = element.hint {
            textField.placeholder = placeholder
        }
        
        if let text = element.value {
            textField.text = text
        }
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(textField)
        } else {
            superview.addSubview(textField)
        }
        self.uiControls.append(textField)
        
        // Constraints
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.snp.makeConstraints { (make) in
            var superviewOrientation = FrameType.none
            
            if let superviewElement = superviewElement as? Frame {
                superviewOrientation = superviewElement.orientation
            }
            FaseConstraintsMaker.makeConstraints(make: make, elementType: ElementType.select, view: textField, in: superview, superviewOrientation: superviewOrientation)
        }
        
    }
    
    private func drawContactPicker(for element: ContactPicker, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        var superviewElement: Element?
        
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
            superviewElement = self.viewModel?.element(with: parentId)
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
        textField.delegate = self.viewModel
        textField.faseElementId = id
        if let parentId = parentElementId {
            textField.navigationElementId = parentId
        }
        
        self.y += textField.frame.size.height
        
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
        
        // Constraints
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.snp.makeConstraints { (make) in
            var superviewOrientation = FrameType.none
            
            if let superviewElement = superviewElement as? Frame {
                superviewOrientation = superviewElement.orientation
            }
            FaseConstraintsMaker.makeConstraints(make: make, elementType: ElementType.contactPicker, view: textField, in: superview, superviewOrientation: superviewOrientation)
        }
        
    }
    
    private func drawSwitch(for element: Switch, with id: String, parentElementId: String?) {
        element.faseElementId = id
        
        var superview: UIView! = self.view
        var superviewElement: Element?
        
        if let parentId = parentElementId, let parentView = self.view(with: parentId) {
            superview = parentView
            superviewElement = self.viewModel?.element(with: parentId)
        }
        
        let x = self.getXForElement(with: self.maxWidth)
        let y = self.y
        let width = UIElementsWidth.switch.rawValue
        let height = UIElementsHeight.switch.rawValue
        let frame = CGRect(x: x, y: y, width: width, height: height)
        
        let `switch` = UISwitch(frame: frame)
        `switch`.faseElementId = id
        
        self.y += `switch`.frame.size.height
        
        let switchStackView = UIStackView(arrangedSubviews: [`switch`])
        switchStackView.axis = .horizontal
        switchStackView.distribution = .fill
        switchStackView.spacing = 5.0
        
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(switchStackView)
        } else {
            superview.addSubview(switchStackView)
        }
        self.uiControls.append(`switch`)
        
        // Constraints
        switchStackView.translatesAutoresizingMaskIntoConstraints = false
        
        switchStackView.snp.makeConstraints { (make) in
            make.height.equalTo(`switch`.frame.height)
            
            var superviewOrientation = FrameType.none
            
            if let superviewElement = superviewElement as? Frame {
                superviewOrientation = superviewElement.orientation
            }
            FaseConstraintsMaker.makeConstraints(make: make, elementType: ElementType.switchElement, view: switchStackView, in: superview, superviewOrientation: superviewOrientation)
            
            if let align = element.align {
                switch align {
                case .left:
                    make.leading.equalToSuperview().offset(5)
                    break
                    
                case .right:
                    make.trailing.equalToSuperview().offset(-5)
                    break
                    
                case .center:
                    make.centerX.equalToSuperview()
                    break
                }
            }
            
        }
        
        if let text = element.text {
            let x = `switch`.frame.maxX
            let y = `switch`.frame.minY
            let width = UIElementsWidth.textField.rawValue
            let height = UIElementsHeight.textField.rawValue
            
            let label = UILabel(frame: CGRect(x: x, y: y, width: width, height: height))
            
            label.text = text
            
            switchStackView.addArrangedSubview(label)
            //            superview.addSubview(label)
            //
            //            // Constraints
            //            label.translatesAutoresizingMaskIntoConstraints = false
            //
            //            label.snp.makeConstraints({ (make) in
            //                make.leading.equalTo(`switch`.snp.trailing).offset(10)
            //                make.height.equalTo(`switch`.snp.height)
            //                make.centerY.equalTo(`switch`.snp.centerY)
            //            })
        }
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
    
    private func drawStackViewSubstrateView(id: String, superview: UIView, height: CGFloat) {
        let x = 0
        let y = 0
        let width = Int(superview.frame.width)
        
        let stackView = UIStackView(frame: CGRect(x: x, y: y, width: width, height: Int(height)))
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.faseElementId = id
        stackView.isUserInteractionEnabled = true
        stackView.tag = -2
        
        stackView.spacing = 5.0
        stackView.layoutMargins = UIEdgeInsetsMake(5, 5, 5, 5)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        superview.addSubview(stackView)
        self.uiControls.append(stackView)
        
        // Constraints
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.snp.makeConstraints { (make) in
            stackView.snp.remakeConstraints({ newMake in
                
                if superview.tag == 100 {
                    make.top.equalToSuperview().offset(64)
                    
                    //                    if element.hasMaxElements() == true && element.size == .max {
                    //                        make.bottom.equalToSuperview()
                    //                    }
                } else {
                    make.top.equalToSuperview()
                }
                
                // Also
                if self.viewModel?.screen.hasElementWithMaxSize() == true {
                    make.bottom.equalToSuperview()
                } else {
                    make.height.equalTo(height)
                }
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                
                make.width.equalToSuperview()
            })
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

