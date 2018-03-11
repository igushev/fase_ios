//
//  FaseViewController.swift
//  TestJsonIOS
//
//  Created by Alexey Bidnyk on 3/6/18.
//  Copyright © 2018 Alexey Bidnyk. All rights reserved.
//

import UIKit

protocol Fase {
    var screen: Screen! { get set }    
}

class FaseViewController: UIViewController, Fase {
    
    // MARK: - Fase
    
    var screen: Screen!
    
    init(with screen: Screen) {
        self.screen = screen
        super.init(nibName: nil, bundle: nil)
    }
    
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
