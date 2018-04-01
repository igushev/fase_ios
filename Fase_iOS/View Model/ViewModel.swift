//
//  ViewModel.swift
//  Fase_iOS
//
//  Created by Alexey Bidnyk on 3/14/18.
//  Copyright © 2018 Fase. All rights reserved.
//

import UIKit

protocol Fase {
    var screen: Screen! { get set }
}

class FaseViewModel: NSObject, Fase {
    
    var screen: Screen!
    weak var router: Router?
    var screenDrawer: ScreenDrawer!
    
    var isNeedTabBar: Bool!
    var isNeedTableView: Bool!
    private(set) var screenUpdateTimer: Timer!
    
    
    init(with screen: Screen) {
        super.init()
        
        self.screen = screen
        self.isNeedTabBar = (self.screen.navigationElement() != nil)
        self.isNeedTableView = self.screen.hasFrameElements()
        self.screenUpdateTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(sendScreenUpdateRequest), userInfo: nil, repeats: true)
    }
    
    //    func redrawElements() {
    //        self.screenDrawer.resetScreen()
    //        self.drawElements()
    //    }
    
    func drawElements() {
        self.screenDrawer.viewModel = self
        self.screenDrawer.draw(elements: self.screen.idElementList)
    }
    
    // MARK: - Actions
    
    @objc func onClick(_ sender: UIButton) {
        print("Catch sender \(sender.faseElementId)")
        
        self.sendCallbackRequest(for: sender.faseElementId, navigationId: sender.navigationElementId)
    }
    
    // MARK: - Screen update request
    
    @objc func sendScreenUpdateRequest() {
        let screenUpdate = ScreenUpdate(elementsUpdate: self.elementsUpdate(), device: Device.currentDevice())
        APIClientService.screenUpdate(for: screenUpdate!, screenId: self.screen.screenId!) { [weak self] (response, error) in
            guard let strongSelf = self else {
                return
            }
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let elementsUpdate = response?.elementsUpdate {
                    strongSelf.updateScreen(with: elementsUpdate)
                }
                if let screen = response?.screen, let sessionInfo = response?.sessionInfo {
                    APIClientService.saveNewSessionInfo(sessionInfo: sessionInfo)
                    
                    let viewModel = FaseViewModel(with: screen)
                    viewModel.router = strongSelf.router
                    strongSelf.router?.displayViewController(with: viewModel)
                }
            }
        }
    }
    
    // MARK: - Send callback request
    
    // TODO: - Refactor callback request. Add array with nested ids
    
    func sendCallbackRequest(for elementId: String, navigationId: String?) {
        var elementIds = [elementId]
        if let navigationId = navigationId {
            elementIds.insert(navigationId, at: 0)
        }
        var method = "on_click"
        var locale: Locale? = nil
        
        if let element = self.element(with: elementId), let countryCode = NSLocale.current.regionCode {
            locale = element.isRequestLocale == true ? Locale(countryCode: countryCode) : nil
            
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            switch elementType {
            case .button:
                method = (element as! Button).onClick.method
                break
                
            case .label:
                method = (element as! Label).onClick.method
                break
                
            case .frame:
                method = (element as! Frame).onClick.method
                break
                
            case .menuItem:
                method = (element as! MenuItem).onClick.method
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
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let screen = response?.screen, let sessionInfo = response?.sessionInfo {
                    APIClientService.saveNewSessionInfo(sessionInfo: sessionInfo)
                    
                    let viewModel = FaseViewModel(with: screen)
                    viewModel.router = strongSelf.router
                    strongSelf.router?.displayViewController(with: viewModel)
                }
                if let resources = response?.resources {
                    ResourcesService.saveResources(resources)
                }
            }
        }
    }
    
    func sendCallbackRequest(for elementIds: [String]) {
        let method = "on_click"
        let elementCallback = ElementCallback(elementsUpdate: self.elementsUpdate(), elementIds: elementIds, method: method, locale: nil, device: Device.currentDevice())
        
        APIClientService.elementCallback(for: elementCallback!, screenId: self.screen.screenId!) { [weak self] (response, error) in
            guard let strongSelf = self else {
                return
            }
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let screen = response?.screen {
                    
                    let viewModel = FaseViewModel(with: screen)
                    viewModel.router = strongSelf.router
                    strongSelf.router?.displayViewController(with: viewModel)
                }
            }
        }
    }
    
    func elementsUpdate() -> ElementsUpdate? {
        var elementsUpdate = ElementsUpdate()
        
        for control in screenDrawer.uiControls {
            if control is UITextField {
                let textField = control as! UITextField
                
                if let text = textField.text, text.isEmpty == false {
                    elementsUpdate.valueArray?.append(text)
                    
                    if let parentElementId = textField.navigationElementId {
                        elementsUpdate.arrayArrayIds?.append([parentElementId, textField.faseElementId])
                    } else {
                        elementsUpdate.arrayArrayIds?.append([textField.faseElementId])
                    }
                }
            }
            
            if control is UITextView {
                let textView = control as! UITextView
                
                if let text = textView.text, text.isEmpty == false {
                    elementsUpdate.valueArray?.append(text)
                    
                    if let parentElementId = textView.navigationElementId {
                        elementsUpdate.arrayArrayIds?.append([parentElementId, textView.faseElementId])
                    } else {
                        elementsUpdate.arrayArrayIds?.append([textView.faseElementId])
                    }
                }
            }
        }
        
        if elementsUpdate.valueArray?.count == 0 && elementsUpdate.arrayArrayIds?.count == 0 {
            return nil
        }
        
        return elementsUpdate
    }
    
    // MARK: - Elements update handling
    
    func updateScreen(with elementsUpdate: ElementsUpdate) {
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
        if let elementId = id, let element = self.element(with: elementId), let uiElement = self.uiElement(with: elementId) {
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            switch elementType {
            case .label:
                (uiElement as! UILabel).text = newValue
                break
                
            case .text:
                if (element as! Text).multiline == true {
                    (uiElement as! UITextView).text = newValue
                } else {
                    (uiElement as! UITextField).text = newValue
                }
                
            default:
                break
            }
        }
    }
    
    
    // MARK: - Elements help methods
    
    func element(with id: String) -> VisualElement? {
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
        if textView.textColor == UIColor.lightGray {
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

