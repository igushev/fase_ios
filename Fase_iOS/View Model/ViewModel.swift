//
//  ViewModel.swift
//  Fase_iOS
//
//  Created by Alexey Bidnyk on 3/14/18.
//  Copyright © 2018 Fase. All rights reserved.
//

import UIKit
import WebKit
import GooglePlaces
import ContactsUI

protocol Fase {
    var screen: Screen! { get set }
}
typealias ContextMenuCallback = (_ sender: UIView, _ button: Button) -> Void

enum FaseDateFormat: String {
    case server = "yyyy-MM-dd'T'HH:mm:ss"
    case printDate = "yyyy-MM-dd"
    case printTime = "h:mm a"
}

class FaseViewModel: NSObject, Fase {
    
    var screen: Screen!
    weak var router: Router?
    var screenDrawer: ScreenDrawer!
    
    var contextMenuCallback: ContextMenuCallback?
    
    var isNeedTabBar: Bool!
    var isNeedTableView: Bool!
    private(set) var screenUpdateTimer: Timer!
    
    var oldElementsUpdate: ElementsUpdate?
    
    var pickerToollBar: UIToolbar?
    var serverDateFormatter: DateFormatter {
        return DateFormatter(withFormat: FaseDateFormat.server.rawValue, locale: "US")
    }
    var printDateFormatter: DateFormatter {
        return DateFormatter(withFormat: FaseDateFormat.printDate.rawValue, locale: "US")
    }
    var printTimeFormatter: DateFormatter {
        return DateFormatter(withFormat: FaseDateFormat.printTime.rawValue, locale: "US")
    }
    
    // Array that stores different pickers
    var pickers: [String: UIView]?
    var pickersToolbars: [String: UIToolbar]?
    
    var isElementCallbackProcessing = false
    
    init(with screen: Screen) {
        super.init()
        
        self.screen = screen
        self.isNeedTabBar = (self.screen.navigationElement() != nil)
        self.isNeedTableView = self.screen.hasFrameElements()
        self.screenUpdateTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(sendScreenUpdateRequest), userInfo: nil, repeats: true)
        self.pickers = [:]
        self.pickersToolbars = [:]
    }
    
    func drawElements() {
        self.screenDrawer.viewModel = self
        
        self.screenDrawer.datePickerSetupBlock = { [weak self] textField in
            guard let strongSelf = self else {
                return
            }
            if let pickers = strongSelf.pickers, let pickersToolbars = strongSelf.pickersToolbars, let elementId = textField.faseElementId {
                textField.inputAccessoryView = pickersToolbars[elementId]
                textField.inputView = pickers[elementId] as! UIDatePicker
            }
        }
        
        self.screenDrawer.pickerSetupBlock = { [weak self] textField in
            guard let strongSelf = self else {
                return
            }
            if let pickers = strongSelf.pickers, let pickersToolbars = strongSelf.pickersToolbars, let elementId = textField.faseElementId {
                textField.inputAccessoryView = pickersToolbars[elementId]
                textField.inputView = pickers[elementId] as! UIPickerView
            }
        }
        
        self.screenDrawer.draw(elements: self.screen.idElementList)
        self.oldElementsUpdate = self.elementsUpdate()
    }
    
    // MARK: - Actions
    
    @objc func onClickBarButtonItem(_ sender: UIView) {
        print("Catch sender \(sender.faseElementId)")
        
        if let elementId = sender.faseElementId {
            if let button = self.element(with: elementId) as? Button, let _ = button.contextMenu(), let contextMenuCallback = self.contextMenuCallback {
                contextMenuCallback(sender, button)
                return
            }
            self.sendCallbackRequest(for: elementId, completion: nil)
        }
    }
    
    @objc func onClick(_ sender: UIView) {
        print("Catch sender \(sender.faseElementId)")
        
        if let elementId = sender.faseElementId {
            if let button = self.element(with: elementId) as? Button, let _ = button.contextMenu(), let contextMenuCallback = self.contextMenuCallback {
                contextMenuCallback(sender, button)
                return
            }
            if let button = self.element(with: elementId) as? Button, let _ = button.onClick {
                let ids = sender.nestedElementsIds()
                self.sendCallbackRequest(for: ids)
                return
            }
        }
    }
    
    @objc func onRefresh(_ screenId: String?, completion: @escaping () -> Void) {
        if let screenId = screenId {
            self.sendCallbackRequest(for: screenId, method: "on_refresh", completion: completion)
        }
    }
    
    @objc func onMore(_ sender: UIView) {
        print("Catch sender \(sender.faseElementId)")
        
    }
    
    // On frame tap
    @objc func onClickGestureRecognizer(_ sender: UITapGestureRecognizer) {
        self.screenDrawer.view.endEditing(true)
        
        if let view = sender.view {
            
            //if let tappedView = view.hitTest(point, with: nil),
            
            if let elementId = view.faseElementId, let frame = self.element(with: elementId) as? Frame, let _ = frame.onClick {
                let nestedElementsIds = view.nestedElementsIds()
                self.sendCallbackRequest(for: nestedElementsIds)
            } else if let elementId = view.faseElementId, let image = self.element(with: elementId) as? Image, let _ = image.onClick {
                let nestedElementsIds = view.nestedElementsIds()
                self.sendCallbackRequest(for: nestedElementsIds)
            } else if let elementId = view.faseElementId, let label = self.element(with: elementId) as? Label, let _ = label.onClick {
                let nestedElementsIds = view.nestedElementsIds()
                self.sendCallbackRequest(for: nestedElementsIds)
            }
        }
        
    }
    
    @objc func onCancelPickerItem(_ sender: UIBarButtonItem) {
        // TODO: - Clean select element and date element if cancel - ???
        self.screenDrawer.view.endEditing(true)
    }
    
    @objc func onOkPickerItem(_ sender: UIBarButtonItem) {
        if let senderId = sender.faseElementId, let textField = self.screenDrawer.view(with: senderId) as? UITextField {
            if let element = self.element(with: senderId) {
                let elementType = ElementType(with: element.class)
                
                switch elementType {
                    
                case .dateTimePicker:
                    if let datePickerElement = self.screen.datePickerElement(elementId: element.faseElementId!), let datePicker = self.pickers![senderId] as? UIDatePicker  {
                        datePickerElement.datetime = datePicker.date
                        if datePickerElement.type == DateTimePickerType.time {
                            textField.text = self.printTimeFormatter.string(from: datePicker.date)
                        } else {
                            textField.text = self.printDateFormatter.string(from: datePicker.date)
                        }
                        
                    }
                    break
                    
                case .select:
                    if let selectElement = self.screen.selectElement(elementId: element.faseElementId!), let value = selectElement.value {
                        selectElement.value = value
                        textField.text = value
                    }
                    break
                    
                default:
                    break
                }
            }
        }
        //        if let senderId = sender.faseElementId, let textField = self.screenDrawer.view(with: senderId) as? UITextField {
        //
        //        }
        
        self.screenDrawer.view.endEditing(true)
    }
    
    @objc func onSelectPlace(_ sender: UITextField) {
        let placePickerController = GMSAutocompleteViewController()
        placePickerController.faseElementId = sender.faseElementId
        placePickerController.delegate = self
        
        if let elementId = sender.faseElementId, let placePicker = self.screen.placePickerElement(elementId: elementId) {
            let filter = GMSAutocompleteFilter()
            
            switch placePicker.type {
                
            case .city:
                filter.type = .city
                break
                
            default:
                filter.type = .noFilter
                break
            }
            placePickerController.autocompleteFilter = filter
        }
        
        self.router?.presentViewController(viewController: placePickerController)
    }
    
    @objc func onSliderValueChanged(_ sender: UISlider) {
        if let elementId = sender.faseElementId, let slider = self.element(with: elementId) as? Slider {
            sender.value = round(sender.value / slider.step) * slider.step
        }
    }
    
    @objc func onDismissKeyboard() {
        self.screenDrawer.view.endEditing(true)
    }
    
    // MARK: - Screen update request
    
    @objc func sendScreenUpdateRequest() {
        if self.isElementCallbackProcessing == true {
            return
        }
        
        let elementsUpdate = self.elementsUpdate()
        
        let summaryElementsUpdates = elementsUpdate?.differenceFrom(oldElementsUpdate: self.oldElementsUpdate)
        let screenUpdate = ScreenUpdate(elementsUpdate: summaryElementsUpdates, device: Device.currentDevice())
        
        APIClientService.screenUpdate(for: screenUpdate!, screenId: self.screen.screenId!) { [weak self] (response, error) in
            guard let strongSelf = self else {
                return
            }
            
            if let error = error, error.code == -1009 {
                strongSelf.router?.processResponse(response: response, error: nil, for: strongSelf, retryApiCall: APIClient.shared.lastCalledApiFunc)
            } else {
                strongSelf.router?.processResponse(response: response, error: error, for: strongSelf, retryApiCall: APIClient.shared.lastCalledApiFunc)
            }
            
            strongSelf.oldElementsUpdate = elementsUpdate
        }
    }
    
    // MARK: - Element callback request
    
    // for for bar button item, on_refresh, on_more
    func sendCallbackRequest(for elementId: String, method: String = "on_click", completion: (() -> Void)?) {
        self.isElementCallbackProcessing = true
        
        let elementIds: Array<String> = (elementId.isEmpty == true) ? [] : [elementId]
        
        let elementCallback = ElementCallback(elementsUpdate: self.elementsUpdate(), elementIds: elementIds, method: method, locale: nil, device: Device.currentDevice())
        
        APIClientService.elementCallback(for: elementCallback!, screenId: self.screen.screenId!) { [weak self] (response, error) in
            guard let strongSelf = self else {
                return
            }
            if let completion = completion {
                completion()
            }
            strongSelf.isElementCallbackProcessing = false
            strongSelf.router?.processResponse(response: response, error: error, for: strongSelf, retryApiCall: APIClient.shared.lastCalledApiFunc)
        }
    }
    
    // for another ui elements
    func sendCallbackRequest(for elementIds: [String]) {
        self.isElementCallbackProcessing = true
        
        var method = "on_click"
        var locale: Locale? = nil
        
        if let element = self.element(with: elementIds.last!), let countryCode = NSLocale.current.regionCode {
            locale = element.isRequestLocale == true ? Locale(countryCode: countryCode) : nil
            
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            switch elementType {
            case .button:
                if let elementMethod = (element as! Button).onClick {
                    method = elementMethod.method
                }
                break
                
            case .label:
                if let elementMethod = (element as! Label).onClick {
                    method = elementMethod.method
                }
                break
                
            case .frame:
                if let elementMethod = (element as! Frame).onClick {
                    method = elementMethod.method
                }
                break
                
            case .menuItem:
                if let elementMethod = (element as! MenuItem).onClick {
                    method = elementMethod.method
                }
                break
                
            case .contactPicker:
                if let elementMethod = (element as! ContactPicker).onPick {
                    method = elementMethod.method
                }
                break
                
            default:
                break
            }
        }
        
        let elementCallback = ElementCallback(elementsUpdate: self.elementsUpdate(), elementIds: elementIds, method: method, locale: locale, device: Device.currentDevice())
        
        APIClientService.elementCallback(for: elementCallback!, screenId: self.screen.screenId!) { [weak self] (response, error) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.isElementCallbackProcessing = false
            strongSelf.router?.processResponse(response: response, error: error, for: strongSelf, retryApiCall: APIClient.shared.lastCalledApiFunc)
        }
    }
    
    func elementsUpdate() -> ElementsUpdate? {
        var elementsUpdate = ElementsUpdate()
        
        if screenDrawer == nil {
            return nil
        }
        
        for control in screenDrawer.uiControls {
            if control is UITextField {
                let textField = control as! UITextField
                let text = textField.text
                let idsArray = textField.nestedElementsIds()
                
                if let element = self.elementButNotFrame(with: textField.faseElementId!) {
                    let elementTypeString = element.`class`
                    let elementType = ElementType(with: elementTypeString)
                    
                    switch elementType {
                        
                    case .contactPicker:
                        var name = ""
                        if let elementId = textField.faseElementId, let contactPickerElement = self.screen.contactPickerElement(elementId: elementId), let contact = contactPickerElement.contact, let contactJsonString = contact.toJSONString() {
                            name = contactJsonString
                        }
                        elementsUpdate.valueArray?.append(name)
                        elementsUpdate.arrayArrayIds?.append(idsArray)
                        
                    case .dateTimePicker:
                        var dateString = ""
                        if let elementId = textField.faseElementId, let datePickerElement = self.screen.datePickerElement(elementId: elementId), let date = datePickerElement.datetime {
                            dateString = self.serverDateFormatter.string(from: date)
                        }
                        elementsUpdate.valueArray?.append(dateString)
                        elementsUpdate.arrayArrayIds?.append(idsArray)
                        
                    case .placePicker:
                        var placeString = ""
                        if let elementId = textField.faseElementId, let placePickerElement = self.screen.placePickerElement(elementId: elementId), let place = placePickerElement.place, let placeJsonString = place.toJSONString() {
                            placeString = placeJsonString
                        }
                        elementsUpdate.valueArray?.append(placeString)
                        elementsUpdate.arrayArrayIds?.append(idsArray)
                        
                    case .select:
                        var value = ""
                        if let elementId = textField.faseElementId, let selectElement = self.screen.selectElement(elementId: elementId), let val = selectElement.value {
                            value = val
                        }
                        elementsUpdate.valueArray?.append(value)
                        elementsUpdate.arrayArrayIds?.append(idsArray)
                        
                    default:
                        elementsUpdate.valueArray?.append(text?.isEmpty == false ? text! : "")
                        elementsUpdate.arrayArrayIds?.append(idsArray)
                    }
                }
                
            }
            
            if control is UITextView {
                let textView = control as! UITextView
                var text = ""
                let idsArray = textView.nestedElementsIds()
                
                if textView.textColor != UIColor.FaseColors.placeholderColor {
                    text = textView.text
                }
                
                elementsUpdate.valueArray?.append(text)
                elementsUpdate.arrayArrayIds?.append(idsArray)
            }
            
            if control is UISwitch {
                let `switch` = control as! UISwitch
                let isOn = `switch`.isOn
                let idsArray = `switch`.nestedElementsIds()
                
                elementsUpdate.valueArray?.append(isOn == true ? "1" : "0")
                elementsUpdate.arrayArrayIds?.append(idsArray)
            }
            
            if control is UISlider {
                let slider = control as! UISlider
                let value = slider.value
                let idsArray = slider.nestedElementsIds()
                
                elementsUpdate.valueArray?.append("\(value)")
                elementsUpdate.arrayArrayIds?.append(idsArray)
            }
        }
        
        if elementsUpdate.valueArray?.count == 0 && elementsUpdate.arrayArrayIds?.count == 0 {
            return nil
        }
        
        return elementsUpdate
    }
    
    // MARK: - Elements update handling
    
    func updateScreen(with elementsUpdate: ElementsUpdate) {
        // Update oldElementsUpdate
        self.oldElementsUpdate?.update(with: elementsUpdate)
        
        if let elementsToUpdateCount = elementsUpdate.valueArray?.count {
            for i in 0...elementsToUpdateCount - 1 {
                if let values = elementsUpdate.valueArray, let elementsIds = elementsUpdate.arrayArrayIds {
                    let elementId = elementsIds[i].last
                    let value = values[i]
                    self.updateElement(with: elementId, newValue: value)
                }
            }
        }
    }
    
    func updateElement(with id: String?, newValue: String?) {
        if let elementId = id, let element = self.elementButNotFrame(with: elementId), let uiElement = self.uiElement(with: elementId) {
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            switch elementType {
            case .label:
                (uiElement as! UILabel).text = newValue
                break
                
            case .text:
                if (element as! Text).multiline == true {
                    (uiElement as! UITextView).text = newValue
                    
                    // change text color
                    if (uiElement as! UITextView).textColor == UIColor.FaseColors.placeholderColor {
                        (uiElement as! UITextView).textColor = UIColor.black
                    }
                } else {
                    if (uiElement as! UITextField).isFirstResponder == true {
                        break
                    }
                    (uiElement as! UITextField).text = newValue
                }
                break
                
            case .switchElement:
                if let value = newValue {
                    let isOn = NSString(string: value).boolValue
                    (uiElement as! UISwitch).isOn = isOn
                }
                break
                
            case .select:
                (uiElement as! UITextField).text = newValue
                break
                
            case .dateTimePicker:
                if let dateString = newValue, let newDate = self.serverDateFormatter.date(from: dateString) {
                    if (element as! DateTimePicker).type == DateTimePickerType.time {
                        (uiElement as! UITextField).text = self.printTimeFormatter.string(from: newDate)
                    } else {
                        (uiElement as! UITextField).text = self.printDateFormatter.string(from: newDate)
                    }
                }
                break
                
            case .contactPicker:
                if let value = newValue, let contact = Contact(JSONString: value) {
                    (uiElement as! UITextField).text = contact.displayName
                }
                break
                
            case .placePicker:
                if let value = newValue, let place = Place(JSONString: value) {
                    (uiElement as! UITextField).text = place.placeString(for: (element as! PlacePicker).type)
                }
                break
                
            case .slider:
                if let value = (newValue as NSString?)?.floatValue {
                    (uiElement as! UISlider).value = value
                }
                break
                
            default:
                break
            }
        }
    }
    
    
    // MARK: - Elements help methods
    
    func element(with id: String) -> VisualElement? {
        for element in self.screenDrawer.elements {
            if element is VisualElement {
                if let elementId = (element as! VisualElement).faseElementId, id == elementId {
                    return element as? VisualElement
                }
            }
        }
        return nil
    }
    
    func elementButNotFrame(with id: String) -> VisualElement? {
        for element in self.screenDrawer.elements {
            if type(of: element) != Frame.self {
                if element is VisualElement {
                    if let elementId = (element as! VisualElement).faseElementId, id == elementId {
                        return element as? VisualElement
                    }
                }
            }
        }
        return nil
    }
    
    func uiElement(with id: String) -> UIView? {
        for view in self.screenDrawer.uiControls {
            if id == view.faseElementId {
                return view
            }
        }
        return nil
    }
    
}

extension FaseViewModel: UITextViewDelegate {
    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.FaseColors.placeholderColor {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            //            textView.bounds = CGRect(x: textView.frame.minX, y: textView.frame.minY, width: textView.bounds.width, height: textView.bounds.height + 30)
        }
        return true
    }
    
}

extension FaseViewModel: UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let elementId = textField.faseElementId, let _ = self.screen.placePickerElement(elementId: elementId) {
            self.onSelectPlace(textField)
            return false
        }
        if let elementId = textField.faseElementId, let _ = self.screen.contactPickerElement(elementId: elementId) {
            let picker = CNContactPickerViewController()
            picker.faseElementId = textField.faseElementId
            picker.delegate = self
            picker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0")
            picker.predicateForSelectionOfContact = NSPredicate(format: "phoneNumbers.@count == 1")
            picker.predicateForSelectionOfProperty = NSPredicate(format: "key == 'phoneNumbers'")
            self.router?.presentViewController(viewController: picker)
            return false
            
        }
        return true
    }
}

extension FaseViewModel: GMSAutocompleteViewControllerDelegate {
    
    // MARK: - GMSAutocompleteViewControllerDelegate
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        if let elementId = viewController.faseElementId, let placePickerElement = self.screen.placePickerElement(elementId: elementId), let textField = self.screenDrawer.view(with: elementId) as? UITextField {
            let fasePlace = Place.place(with: place)
            
            placePickerElement.place = fasePlace
            
            textField.text = fasePlace.placeString(for: placePickerElement.type)
            
            viewController.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
}

extension FaseViewModel: UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - UIPickerViewDataSource, UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let elementId = pickerView.faseElementId, let selectElement = self.screen.selectElement(elementId: elementId), let items = selectElement.items {
            return items.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let elementId = pickerView.faseElementId, let selectElement = self.screen.selectElement(elementId: elementId), let items = selectElement.items {
            return items[row]
        }
        return nil
    }
    
    // ?
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let elementId = pickerView.faseElementId, let selectedElement = self.screen.selectElement(elementId: elementId), let items = selectedElement.items {
            selectedElement.value = items[row]
        }
    }
}

extension FaseViewModel: CNContactPickerDelegate {
    
    // MARK: - CNContactPickerDelegate
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        if let elementId = picker.faseElementId, let textField = self.screenDrawer.view(with: elementId) as? UITextField, let contactPicker = self.screen.contactPickerElement(elementId: elementId) {
            if let phone = contact.phoneNumbers.first?.value.stringValue {
                let faseContact = Contact(name: contact.givenName + " " + contact.familyName, phone: phone)
                contactPicker.contact = faseContact
                
                self.fill(textField: textField, with: faseContact)
            }
            
            picker.dismiss(animated: true, completion: nil)
            
            if let _ = contactPicker.onPick {
                let ids = textField.nestedElementsIds()
                self.sendCallbackRequest(for: ids)
            }
        }
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        if let elementId = picker.faseElementId, let textField = self.screenDrawer.view(with: elementId) as? UITextField, let contactPicker = self.screen.contactPickerElement(elementId: elementId) {
            if let phoneNumber = contactProperty.value as? CNPhoneNumber {
                let faseContact = Contact(name: contactProperty.contact.givenName + " " + contactProperty.contact.familyName, phone: phoneNumber.stringValue)
                contactPicker.contact = faseContact
                
                self.fill(textField: textField, with: faseContact)
            }
            picker.dismiss(animated: true, completion: nil)
            
            if let _ = contactPicker.onPick {
                let ids = textField.nestedElementsIds()
                self.sendCallbackRequest(for: ids)
            }
        }
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func fill(textField: UITextField, with contact: Contact) {
        textField.text = contact.displayName
    }
}

extension FaseViewModel: WKUIDelegate, WKNavigationDelegate {
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                webView.evaluateJavaScript("document.body.offsetHeight", completionHandler: { (height, error) in
                    let height = height as! CGFloat
                    
                    webView.snp.makeConstraints({ (make) in
                        make.height.equalTo(self.screenDrawer.view.frame.height / 2)
                    })
                })
            }
            
        })
    }
    
    //    func webViewDidFinishLoad(_ webView: UIWebView) {
    //        var frame = webView.frame
    //        frame.size.height = 1
    //        webView.frame = frame
    //
    //        let fittingSize = webView.sizeThatFits(CGSize.zero)
    //        frame.size = fittingSize
    ////        webView.frame = frame
    //
    //        webView.heightAnchor.constraint(equalToConstant: fittingSize.height).isActive = true
    //        webView.widthAnchor.constraint(equalToConstant: fittingSize.width).isActive = true
    //
    //        if let superview = webView.superview as? UIScrollView {
    //            superview.contentSize = fittingSize
    //        }
    //
    //    }
}

