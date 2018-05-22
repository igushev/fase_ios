//
//  ViewController.swift
//  Fase_iOS
//
//  Created by Aleksey on 3/6/18.
//  Copyright © 2018 Fase. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupStackView()
    }
    
    func setupStackView() {
        let label = UILabel(frame: CGRect.zero)
        label.text = "Test Label"
        
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.brown
        
        let button = UIButton(frame: CGRect.zero)
        button.setTitle("Test button", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        
        let stackView = UIStackView(arrangedSubviews: [label, view, button])
        stackView.distribution = .fill
        
        self.view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(50)
        }
    }

}

