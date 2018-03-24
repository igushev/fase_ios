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
    var router: Router!
    var screenDrawer: ScreenDrawer!
    var isNeedTabBar: Bool!
    var isNeedTableView: Bool!
    
    
    init(with screen: Screen) {
        self.screen = screen
        self.isNeedTabBar = (self.screen.navigationElement() != nil)
        self.isNeedTableView = self.screen.hasFrameElements()
    }
    
    func drawElements() {
        self.screenDrawer.viewModel = self
        self.screenDrawer.draw(elements: self.screen.idElementList)
    }
    
    // MARK: - Actions
    
    @objc func onClick(_ sender: UIButton) {
        print("Catch sender \(sender.faseElementId)")
        
        self.sendCallbackRequest(for: sender.faseElementId, navigationId: sender.navigationElementId)
    }
    
    // TODO: - Create updating server response
    
    // MARK: - Elements update request
    
    func sendElementsUpdateRequest() {
        //        APIClientService.screenUpdate(for: screenUpdate) { [weak self] (response, error) in
        //            if let error = error {
        //                print(error.localizedDescription)
        //            } else {
        //                if let screen = response?.screen {
        //                    //                    let viewModel = FaseViewModel(with: screen)
        //                    //                    self?.router?.displayViewController(with: viewModel)
        //                }
        //            }
        //        }
    }
    
    // MARK: - Send callback request
    
    // TODO: - Refactor callback request. Add array with nested ids
    
    func sendCallbackRequest(for elementId: String, navigationId: String?) {
        var elementIds = [elementId]
        if let navigationId = navigationId {
            elementIds.insert(navigationId, at: 0)
        }
        let method = "on_click"
        var locale: Locale? = nil
        
        if let element = self.element(with: elementId), let countryCode = NSLocale.current.regionCode {
            locale = element.isRequestLocale == true ? Locale(countryCode: countryCode) : nil
        }
        
        let elementCallback = ElementCallback(elementsUpdate: self.elementsUpdate(), elementIds: elementIds, method: method, locale: locale, device: Device.currentDevice())
        
        APIClientService.elementCallback(for: elementCallback!, screenId: self.screen.screenId!) { [weak self] (response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let screen = response?.screen, let sessionInfo = response?.sessionInfo {
                    APIClientService.saveNewSessionInfo(sessionInfo: sessionInfo)
                    
                    let viewModel = FaseViewModel(with: screen)
                    viewModel.router = self?.router
                    self?.router?.displayViewController(with: viewModel)
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
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let screen = response?.screen {
                    
                    let viewModel = FaseViewModel(with: screen)
                    viewModel.router = self?.router
                    self?.router?.displayViewController(with: viewModel)
                }
            }
        }
    }
    
    func elementsUpdate() -> ElementsUpdate? {
        var elementsUpdate = ElementsUpdate()
        
        for control in screenDrawer.uiControls {
            if control is UITextField {
                let textField = control as! UITextField
                
                guard let text = textField.text, text.isEmpty == false else {
                    break
                }
                
                elementsUpdate.valueArray?.append(text)
                
                if let parentElementId = textField.navigationElementId {
                    elementsUpdate.arrayArrayIds?.append([parentElementId, textField.faseElementId])
                } else {
                    elementsUpdate.arrayArrayIds?.append([textField.faseElementId])
                }
            }
            
            if control is UITextView {
                let textView = control as! UITextView
                
                guard let text = textView.text, text.isEmpty == false else {
                    break
                }
                
                elementsUpdate.valueArray?.append(text)
                
                if let parentElementId = textView.navigationElementId {
                    elementsUpdate.arrayArrayIds?.append([parentElementId, textView.faseElementId])
                } else {
                    elementsUpdate.arrayArrayIds?.append([textView.faseElementId])
                }
            }
        }
        
        if elementsUpdate.valueArray?.count == 0 && elementsUpdate.arrayArrayIds?.count == 0 {
            return nil
        }
        
        return elementsUpdate
    }
    
    func screenUpdate() -> ScreenUpdate {
        var screenUpdate = ScreenUpdate()
        
        return screenUpdate
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

