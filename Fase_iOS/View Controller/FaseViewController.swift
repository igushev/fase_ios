//
//  FaseViewController.swift
//  TestJsonIOS
//
//  Created by Alexey Bidnyk on 3/6/18.
//  Copyright © 2018 Alexey Bidnyk. All rights reserved.
//

import UIKit

let tabBarHeight: CGFloat = 49.0

class FaseViewController: UIViewController {
    
    // MARK: - Fase
    
    var viewModel: FaseViewModel!
    
    
    init(with viewModel: FaseViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavBar()
        self.setupCustomTabBar()
        
        self.viewModel.screenDrawer = ScreenDrawer(with: self.view)
        self.viewModel.drawElements()
        self.decorateView()
    }
    
    // MARK: - setup view
    
    func setupNavBar() {
        self.navigationController?.isNavigationBarHidden = (self.viewModel.screen.title == nil)
        self.navigationController?.title = self.viewModel.screen.title
        
        if let mainButton = self.viewModel.screen.mainButton() {
            let mainButtonBar = UIBarButtonItem(title: mainButton.text, style: .plain, target: self.viewModel, action: #selector(FaseViewModel.onClick(_:)))
            
            self.navigationItem.rightBarButtonItems = [mainButtonBar]
        }
    }
    
    func setupCustomTabBar() {
        if self.viewModel.isNeedTabBar == true {
            var x: CGFloat = 0
            var y = self.view.frame.height - tabBarHeight
            let width = self.view.frame.width
            
            var tabBarView = UIView(frame: CGRect(x: x, y: y, width: width, height: tabBarHeight))
            tabBarView.backgroundColor = UIColor(red: 198/256, green: 198/256, blue: 198/256, alpha: 1.0)
            
            let tabBarItemsCount = self.viewModel.screen.navigationElementButtonsCount()
            
            if let navButtons = self.viewModel.screen.navigationElementButtons(), tabBarItemsCount > 0 {
                x = 0
                y = 0
                let width: CGFloat = self.view.bounds.width / CGFloat(tabBarItemsCount)
                
                for button in navButtons {
                    let uiButton = UIButton(frame: CGRect(x: x, y: y, width: width, height: tabBarHeight))
                    uiButton.setTitle(button.text, for: .normal)
                    uiButton.setImage(UIImage(named: "menu"), for: .normal)
                    uiButton.backgroundColor = UIColor.clear
                    uiButton.titleLabel?.font = uiButton.titleLabel?.font.withSize(10)
                    uiButton.setTitleColor(UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1.0), for: .normal)
                    uiButton.alignVertical(spacing: -40)
                    
                    tabBarView.addSubview(uiButton)
                    
                    x += width
                }
            }
            self.view.addSubview(tabBarView)
        }
    }
    
    func decorateView() {
        self.view.backgroundColor = UIColor.lightGray;
    }
    
}

