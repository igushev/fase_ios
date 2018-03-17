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
    //    lazy var drawer: ScreenDrawer = {
    //        return ScreenDrawer(with: self.view)
    //    }()
    
    
    init(with viewModel: FaseViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = (self.viewModel.screen.title == nil)
        
        self.viewModel.screenDrawer = ScreenDrawer(with: self.view)
        self.viewModel.drawElements()
        self.decorateView()
    }
    
    // MARK: - decorate
    
    func decorateView() {
        self.view.backgroundColor = UIColor.lightGray;
    }
    
}

