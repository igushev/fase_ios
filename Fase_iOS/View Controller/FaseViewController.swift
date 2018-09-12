//
//  FaseViewController.swift
//  TestJsonIOS
//
//  Copyright © 2018 Fase. All rights reserved.
//

import UIKit

class FaseViewController: UIViewController {
    
    // MARK: - Fase
    
    var viewModel: FaseViewModel!
    var alertController: UIAlertController?
    var datePicker: UIDatePicker?
    var picker: UIPickerView?
    
    var spinner: UIActivityIndicatorView!
    var panGRTranslationStartPoint: CGPoint?
    
    
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
        
        self.view.isUserInteractionEnabled = true
        
        let gestureRecognizer = UITapGestureRecognizer(target: self.viewModel, action: #selector(FaseViewModel.onClickGestureRecognizer(_:)))
        self.view.addGestureRecognizer(gestureRecognizer)
        
        if let _ = self.viewModel.screen.onRefresh {
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onDragPanGesture(_:)))
            self.view.addGestureRecognizer(panGestureRecognizer)
            
            spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            spinner.color = UIColor.lightGray
            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.startAnimating()
            self.view.addSubview(spinner)
            spinner.alpha = 0
            
            spinner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            spinner.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 8).isActive = true
        }
        
        if let _ = self.viewModel.screen.onMore {
            
        }
        NotificationCenter.default.addObserver(self, selector: #selector(FaseViewController.keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FaseViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
            var mainButtonBar = UIBarButtonItem(title: mainButton.text, style: .plain, target: self.viewModel, action: #selector(FaseViewModel.onClickBarButtonItem(_:)))
            
            if mainButton.idElementList.count > 0 {
                if let imageElement = mainButton.imageElement() {
                    if let data = ResourcesService.getResource(by: imageElement.fileName), let image = UIImage(data: data), let resizedImage = image.resizedImage(with: CGSize(width: FaseImageWidth.navigationItem.rawValue, height: FaseImageWidth.navigationItem.rawValue)) {
                        
                        let button = UIButton()
                        button.addTarget(self.viewModel, action: #selector(FaseViewModel.onClickBarButtonItem(_:)), for: .touchUpInside)
                        button.setImage(resizedImage, for: .normal)
                        button.faseElementId = mainButton.faseElementId
                        
                        mainButtonBar = UIBarButtonItem(customView: button)
                    }
                }
            }
            
            self.addBarButtonItem(button: mainButtonBar, leftItem: false)
            self.navigationController?.isNavigationBarHidden = false
        }
        
        if let cancelButton = self.viewModel.screen.previousButton() {
            nestedElemetnsIds.append(cancelButton.faseElementId!)
            
            let title = cancelButton.text?.isEmpty == false ? cancelButton.text : "Menu"
            
            var cancelButtonBar = UIBarButtonItem(title: title, style: .plain, target: self.viewModel, action: #selector(FaseViewModel.onClickBarButtonItem(_:)))
            
            if cancelButton.idElementList.count > 0 {
                if let imageElement = cancelButton.imageElement() {
                    if let data = ResourcesService.getResource(by: imageElement.fileName), let image = UIImage(data: data), let resizedImage = image.resizedImage(with: CGSize(width: FaseImageWidth.navigationItem.rawValue, height: FaseImageWidth.navigationItem.rawValue)) {
                        cancelButtonBar = UIBarButtonItem(image: resizedImage, style: .plain, target: self.viewModel, action: #selector(FaseViewModel.onClickBarButtonItem(_:)))
                    }
                }
            }
            cancelButtonBar.faseElementId = cancelButton.faseElementId
            
            self.addBarButtonItem(button: cancelButtonBar, leftItem: true)
            self.navigationController?.isNavigationBarHidden = false
        }
        
        if let nextButton = self.viewModel.screen.nextButton() {
            var nextButtonBar = UIBarButtonItem(title: nextButton.text, style: .plain, target: self.viewModel, action: #selector(FaseViewModel.onClickBarButtonItem(_:)))
            
            if nextButton.idElementList.count > 0 {
                if let imageElement = nextButton.imageElement() {
                    if let data = ResourcesService.getResource(by: imageElement.fileName), let image = UIImage(data: data) {
                        nextButtonBar = UIBarButtonItem(image: image, style: .plain, target: self.viewModel, action: #selector(FaseViewModel.onClickBarButtonItem(_:)))
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
        if let datePickerElements = self.viewModel.screen.datePickerElements(), datePickerElements.isEmpty == false {
            for datePickerElement in datePickerElements {
                let pickerToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
                let cancelItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self.viewModel, action: #selector(FaseViewModel.onCancelPickerItem(_:)))
                let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                let okItem = UIBarButtonItem(title: "Ok", style: .plain, target: self.viewModel, action: #selector(FaseViewModel.onOkPickerItem(_:)))
                okItem.faseElementId = datePickerElement.faseElementId
                
                pickerToolBar.items = [cancelItem, flexibleSpaceItem, okItem]
                
                let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 216))
                datePicker.datePickerMode = .date
                datePicker.faseElementId = datePickerElement.faseElementId
                
                switch datePickerElement.type {
                case .time:
                    datePicker.datePickerMode = .time
                    
                case .date:
                    datePicker.datePickerMode = .date
                    
                case .datetime:
                    datePicker.datePickerMode = .dateAndTime
                    
                default:
                    break
                }
                
                self.viewModel.pickersToolbars![datePickerElement.faseElementId!] = pickerToolBar
                self.viewModel.pickers![datePickerElement.faseElementId!] = datePicker
            }
        }
        
        if let selectElements = self.viewModel.screen.selectElements(), selectElements.isEmpty == false {
            for selectElement in selectElements {
                let pickerToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
                let cancelItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self.viewModel, action: #selector(FaseViewModel.onCancelPickerItem(_:)))
                let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                let okItem = UIBarButtonItem(title: "Ok", style: .plain, target: self.viewModel, action: #selector(FaseViewModel.onOkPickerItem(_:)))
                okItem.faseElementId = selectElement.faseElementId
                
                pickerToolBar.items = [cancelItem, flexibleSpaceItem, okItem]
                
                let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 216))
                picker.dataSource = self.viewModel
                picker.delegate = self.viewModel
                picker.faseElementId = selectElement.faseElementId
                
                self.viewModel.pickersToolbars![selectElement.faseElementId!] = pickerToolBar
                self.viewModel.pickers![selectElement.faseElementId!] = picker
            }
        }
    }
    
    // MARK: - Actions
    // This func will be passed to the view model. It will be called if button has context menu
    
    func openContextMenu(sender: UIView, for button: Button) {
        var nestedElemetnsIds: Array<String> = []
        
        if sender.isMember(of: UIBarButtonItem.self) == false {
            nestedElemetnsIds = sender.nestedElementsIds()
        } else {
            nestedElemetnsIds.append(sender.faseElementId!)
        }
        
        if let menu = button.contextMenu() {
            nestedElemetnsIds.append(menu.faseElementId!)
            
            if let menuItems = button.menuItems() {
                let title = button.text.isEmpty == false ? button.text : "Menu"
                self.alertController = UIAlertController(title: title, message: menu.text, preferredStyle: .actionSheet)
                
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

                if UIDevice.current.userInterfaceIdiom == .pad {
                    self.alertController?.popoverPresentationController?.sourceView = self.view
                    self.alertController?.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    self.alertController?.popoverPresentationController?.permittedArrowDirections = []
                    
                }
            }
        }
        
        self.onContextMenu(nil)
    }
    
    @objc func onContextMenu(_ sender: UIButton?) {
        if let alert = self.alertController {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func onDragPanGesture(_ gr: UIPanGestureRecognizer?) {
        if let panGR = gr {
            if panGR.state == .began {
                self.panGRTranslationStartPoint = panGR.translation(in: self.view)
            }
            if panGR.state == .changed {
                
            }
            if panGR.state == .ended {
                let translationPoint = panGR.translation(in: self.view)
                
                if let startY = self.panGRTranslationStartPoint?.y, (translationPoint.y - startY) >= self.view.frame.height / 3 {
                    self.spinner.alpha = 1
                    self.viewModel.onRefresh("", completion: {
                        self.spinner.alpha = 0
                    })
                }
                
                self.panGRTranslationStartPoint = nil
            }
        }
        
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            // self.view.frame.origin.y = -keyboardSize.height
            let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
            if let scrollView = self.view?.scrollView {
                scrollView.contentInset = contentInsets
                scrollView.scrollIndicatorInsets = contentInsets
                if let view = self.view {
                    var aRect : CGRect = view.frame
                    aRect.size.height -= keyboardSize.height
                    if let activeTextField = self.viewModel.activeTextField {
                        if (!aRect.contains(activeTextField.frame.origin)) {
                            scrollView.scrollRectToVisible(activeTextField.frame, animated: true)
                        }
                    } else if let activeTextView = self.viewModel.activeTextView {
                        if (!aRect.contains(activeTextView.frame.origin)) {
                            scrollView.scrollRectToVisible(activeTextView.frame, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        // self.view.frame.origin.y = 0
        let contentInsets: UIEdgeInsets = UIEdgeInsets.zero
        if let scrollView = self.view?.scrollView {
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }

    // MARK: - deinit
    
    deinit {
        self.viewModel.screenUpdateTimer.invalidate()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}

