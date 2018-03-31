//
//  FaseViewController.swift
//  TestJsonIOS
//
//  Created by Alexey Bidnyk on 3/6/18.
//  Copyright © 2018 Alexey Bidnyk. All rights reserved.
//

import UIKit

class FaseViewController: UIViewController {
    
    // MARK: - Fase
    
    var viewModel: FaseViewModel!
    var alertController: UIAlertController?
    
    
    init(with viewModel: FaseViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.tag = 100
        
        self.setupNavBar()
        
        self.viewModel.screenDrawer = ScreenDrawer(with: self.view)
        self.viewModel.drawElements()
        self.decorateView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let alert = self.viewModel.screen.alertElement() {
            let alertController = UIAlertController(title: "", message: alert.text, preferredStyle: UIAlertControllerStyle.alert)
            for elementTuple in alert.idElementList {
                let buttonId = elementTuple[0] as! String
                let button = elementTuple[1] as! Button
                
                let action = UIAlertAction(title: button.text, style: UIAlertActionStyle.default, handler: { [weak self] (action) in
                    self?.viewModel.sendCallbackRequest(for: [alert.faseElementId!, buttonId])
                    alertController.dismiss(animated: true, completion: nil)
                })
                
                alertController.addAction(action)
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - decorate view
    
    func decorateView() {
        self.view.backgroundColor = UIColor.lightGray;
    }
    
    // MARK: - setup view
    
    func setupNavBar() {
        var nestedElemetnsIds: Array<String> = []
        
        self.navigationController?.isNavigationBarHidden = (self.viewModel.screen.title == nil)
        self.title = self.viewModel.screen.title
        
        if let mainButton = self.viewModel.screen.mainButton() {
            var mainButtonBar = UIBarButtonItem(title: mainButton.text, style: .plain, target: self.viewModel, action: #selector(FaseViewModel.onClick(_:)))
            
            if mainButton.idElementList.count > 0 {
                if let imageElement = mainButton.imageElement() {
                    if let image = ResourcesService.getImage(by: imageElement.fileName), let resizedImage = image.resizedImageForNavBarItem() {
                        mainButtonBar = UIBarButtonItem(image: resizedImage, style: .plain, target: self.viewModel, action: #selector(FaseViewModel.onClick(_:)))
                    }
                }
            }
            mainButtonBar.faseElementId = mainButton.faseElementId
            
            self.addBarButtonItem(button: mainButtonBar, leftItem: false)
            self.navigationController?.isNavigationBarHidden = false
        }
        
        if let cancelButton = self.viewModel.screen.previousButton() {
            nestedElemetnsIds.append(cancelButton.faseElementId!)
            
            var cancelButtonBar = UIBarButtonItem(title: cancelButton.text, style: .plain, target: self.viewModel, action: #selector(FaseViewModel.onClick(_:)))
            
            if cancelButton.idElementList.count > 0 {
                if let imageElement = cancelButton.imageElement() {
                    if let image = ResourcesService.getImage(by: imageElement.fileName), let resizedImage = image.resizedImageForNavBarItem() {
                        cancelButtonBar = UIBarButtonItem(image: resizedImage, style: .plain, target: self.viewModel, action: #selector(FaseViewModel.onClick(_:)))
                    }
                }
                if let menu = cancelButton.contextMenu() {
                    nestedElemetnsIds.append(menu.faseElementId!)
                    
                    let title = cancelButton.text?.isEmpty == false ? cancelButton.text : "Menu"
                    cancelButtonBar = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(FaseViewController.onContextMenu(_:)))
                    
                    if let menuItems = cancelButton.menuItems() {
                        self.alertController = UIAlertController(title: "", message: menu.text, preferredStyle: .actionSheet)
                        
                        for menuItem in menuItems {
                            menuItem.nestedElemetsIds = nestedElemetnsIds
                            menuItem.nestedElemetsIds.append(menuItem.faseElementId!)
                            
                            let action = UIAlertAction(title: menuItem.text, style: .default, handler: { [weak self] action in
                                self?.viewModel.sendCallbackRequest(for: menuItem.nestedElemetsIds)
                            })
                            self.alertController?.addAction(action)
                        }
                    }
                    
                }
            }
            cancelButtonBar.faseElementId = cancelButton.faseElementId
            
            self.addBarButtonItem(button: cancelButtonBar, leftItem: true)
            self.navigationController?.isNavigationBarHidden = false
        }
        
        if let nextButton = self.viewModel.screen.nextButton() {
            var nextButtonBar = UIBarButtonItem(title: nextButton.text, style: .plain, target: self.viewModel, action: #selector(FaseViewModel.onClick(_:)))
            
            if nextButton.idElementList.count > 0 {
                if let imageElement = nextButton.imageElement() {
                    if let image = ResourcesService.getImage(by: imageElement.fileName) {
                        nextButtonBar = UIBarButtonItem(image: image, style: .plain, target: self.viewModel, action: #selector(FaseViewModel.onClick(_:)))
                    }
                }
            }
            nextButtonBar.faseElementId = nextButton.faseElementId
            
            self.addBarButtonItem(button: nextButtonBar, leftItem: false)
            self.navigationController?.isNavigationBarHidden = false
        }
    }
    
    func addBarButtonItem(button: UIBarButtonItem, leftItem: Bool) {
        if self.navigationItem.leftBarButtonItems == nil {
            self.navigationItem.leftBarButtonItems = []
        }
        if self.navigationItem.rightBarButtonItems == nil {
            self.navigationItem.rightBarButtonItems = []
        }
        
        if leftItem == true {
            self.navigationItem.leftBarButtonItems?.append(button)
        } else {
            self.navigationItem.rightBarButtonItems?.append(button)
        }
        
    }
    
    // MARK: - Actions
    
    @objc func onContextMenu(_ sender: UIButton) {
        print("Catch sender \(sender.faseElementId)")
        
        if let alert = self.alertController {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - deinit
    
    deinit {
        self.viewModel.screenUpdateTimer.invalidate()
    }
}

