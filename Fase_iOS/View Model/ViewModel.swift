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

class FaseViewModel: Fase {
    
    var screen: Screen!
    var router: Router!
    var screenDrawer: ScreenDrawer!
    
    
    init(with screen: Screen) {
        self.screen = screen
    }
    
    func drawElements() {
        self.screenDrawer.viewModel = self
        self.screenDrawer.draw(elements: self.screen.idElementList)
    }
    
    @objc func onClick(_ sender: UIButton) {
        print("Catch sender \(sender.faseElementId)")
                
        self.sendCallbackRequest(for: sender.faseElementId)
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
    
    func sendCallbackRequest(for elementId: String) {
        let elementIds = [elementId]
        let method = "on_click"        
        let elementCallback = ElementCallback(elementsUpdate: self.elementsUpdate(), elementIds: elementIds, method: method, locale: nil, device: Device.currentDevice())
        
        APIClientService.elementCallback(for: elementCallback, screenId: self.screen.screenId!) { [weak self] (response, error) in
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
    
    func elementsUpdate() -> ElementsUpdate {
        var elementsUpdate = ElementsUpdate()
        
        for control in screenDrawer.uiControls {
            if control is UITextField {
                let textField = control as! UITextField
                
                elementsUpdate.valueArray?.append(textField.text!)
                elementsUpdate.arrayArrayIds?.append([textField.faseElementId])
            }
            
        }
        
        return elementsUpdate
    }
    
    func screenUpdate() -> ScreenUpdate {
        var screenUpdate = ScreenUpdate()
        
        return screenUpdate
    }
    
}
