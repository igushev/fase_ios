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
    var datePicker: UIDatePicker?
    var picker: UIPickerView?
    
    var gestureRecognizer: UITapGestureRecognizer?
    
    
    init(with viewModel: FaseViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
        self.viewModel.contextMenuCallback = self.openContextMenu(sender:for:)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.tag = 100
        
        self.setupNavBar()
        self.setupPickersIfNedded()
        
        self.viewModel.screenDrawer = ScreenDrawer(with: self.view)
        self.viewModel.drawElements()
        self.decorateView()
        
        self.gestureRecognizer = UITapGestureRecognizer(target: self.viewModel, action: #selector(FaseViewModel.onClickGestureRecognizer(_:)))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(self.gestureRecognizer!)
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func decorateView() {
        self.navigationController?.navigationBar.barTintColor = UIColor.FaseColors.navBarColor
        self.navigationController?.navigationBar.tintColor = UIColor.FaseColors.navBarItemsColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.FaseColors.navBarItemsColor]
        self.view.backgroundColor = UIColor.FaseColors.backgroundColor;
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
                    if let data = ResourcesService.getResource(by: imageElement.fileName), let image = UIImage(data: data), let resizedImage = image.resizedImage(with: CGSize(width: FaseImageWidth.navigationItem.rawValue, height: FaseImageWidth.navigationItem.rawValue)) {
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
            
            let title = cancelButton.text?.isEmpty == false ? cancelButton.text : "Menu"
            
            var cancelButtonBar = UIBarButtonItem(title: title, style: .plain, target: self.viewModel, action: #selector(FaseViewModel.onClick(_:)))
            
            if cancelButton.idElementList.count > 0 {
                if let imageElement = cancelButton.imageElement() {
                    if let data = ResourcesService.getResource(by: imageElement.fileName), let image = UIImage(data: data), let resizedImage = image.resizedImage(with: CGSize(width: FaseImageWidth.navigationItem.rawValue, height: FaseImageWidth.navigationItem.rawValue)) {
                        cancelButtonBar = UIBarButtonItem(image: resizedImage, style: .plain, target: self.viewModel, action: #selector(FaseViewModel.onClick(_:)))
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
                    if let data = ResourcesService.getResource(by: imageElement.fileName), let image = UIImage(data: data) {
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
    
    func setupPickersIfNedded() {
        if let datePickerElement = self.viewModel.screen.datePickerElement() {
            let pickerToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
            let cancelItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self.viewModel, action: #selector(FaseViewModel.onCancelPickerItem(_:)))
            let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let okItem = UIBarButtonItem(title: "Ok", style: .plain, target: self.viewModel, action: #selector(FaseViewModel.onOkPickerItem(_:)))
            okItem.faseElementId = datePickerElement.faseElementId
            
            pickerToolBar.items = [cancelItem, flexibleSpaceItem, okItem]
            
            let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 216))
            datePicker.datePickerMode = .date
            
            self.viewModel.pickersToolbars![datePickerElement.faseElementId!] = pickerToolBar
            self.viewModel.pickers![datePickerElement.faseElementId!] = datePicker
        }
        if let selectElement = self.viewModel.screen.selectElement() {
            let pickerToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
            let cancelItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self.viewModel, action: #selector(FaseViewModel.onCancelPickerItem(_:)))
            let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let okItem = UIBarButtonItem(title: "Ok", style: .plain, target: self.viewModel, action: #selector(FaseViewModel.onOkPickerItem(_:)))
            okItem.faseElementId = selectElement.faseElementId
            
            pickerToolBar.items = [cancelItem, flexibleSpaceItem, okItem]
            
            let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 216))
            picker.dataSource = self.viewModel
            picker.delegate = self.viewModel
            
            self.viewModel.pickersToolbars![selectElement.faseElementId!] = pickerToolBar
            self.viewModel.pickers![selectElement.faseElementId!] = picker
        }
    }
    
    // MARK: - Actions
    // This func will be passed to the view model. It will be called if button has context menu
    
    func openContextMenu(sender: UIView, for button: Button) {
        var nestedElemetnsIds: Array<String> = []
        
        if sender.isMember(of: UIBarButtonItem.self) == false {
            nestedElemetnsIds = sender.nestedElementsIds()
        } else {
            nestedElemetnsIds.append(sender.faseElementId)
        }
        
        if let menu = button.contextMenu() {
            nestedElemetnsIds.append(menu.faseElementId!)
            
            if let menuItems = button.menuItems() {
                self.alertController = UIAlertController(title: "", message: menu.text, preferredStyle: .actionSheet)
                
                for menuItem in menuItems {
                    menuItem.nestedElemetsIds = nestedElemetnsIds
                    menuItem.nestedElemetsIds.append(menuItem.faseElementId!)
                    
                    let action = UIAlertAction(title: menuItem.text, style: .default, handler: { [weak self] action in
                        self?.viewModel.sendCallbackRequest(for: menuItem.nestedElemetsIds)
                    })
                    self.alertController?.addAction(action)
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { [weak self] (action) in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    strongSelf.alertController?.dismiss(animated: true, completion: nil)
                })
                self.alertController?.addAction(cancelAction)
            }
        }
        
        self.onContextMenu(nil)
    }
    
    @objc func onContextMenu(_ sender: UIButton?) {
        if let button = sender {
            print("Catch sender \(button.faseElementId)")
        }
        
        if let alert = self.alertController {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - deinit
    
    deinit {
        self.viewModel.screenUpdateTimer.invalidate()
    }
}

