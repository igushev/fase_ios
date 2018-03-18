//
//  FaseTabBarController.swift
//  Fase_iOS
//
//  Created by Aleksey on 3/17/18.
//  Copyright © 2018 Fase. All rights reserved.
//

import UIKit

class FaseTabBarController: UITabBarController {

    var viewModel: FaseViewModel!
    
    init(with viewModel: FaseViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setup() {
        for tuple in self.viewModel.screen.idElementList {
            let element = tuple[1] as! Element
            
            if element is ElementContainer {
                let elementTypeString = element.`class`
                let elementType = ElementType(with: elementTypeString)
                
                if elementType == ElementType.navigation {
                    self.viewControllers = self.setupContentControllers(with: element as! ElementContainer)
                    break
                }
            }
        }
    }
    
    func setupContentControllers(with element: ElementContainer) -> Array<UIViewController> {
        var viewControllers: Array<UIViewController> = []
        
        var index = 0
        for tuple in element.idElementList {
//            let index = element.idElementList.indexOf(tuple)
            let button = tuple[1] as! Button
            
            let viewController = UIViewController()
            viewController.tabBarItem = UITabBarItem(title: button.text, image: nil, tag: index)
            viewControllers.append(viewController)
            index += 1
        }
        return viewControllers
    }

    

}
