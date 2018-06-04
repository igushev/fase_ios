//
//  FaseConstraintsMaker.swift
//  Fase_iOS
//
//  Created by Alexey Bidnyk on 5/3/18.
//  Copyright © 2018 Fase. All rights reserved.
//

import UIKit
import SnapKit

class FaseConstraintsMaker {
    
    static func makeConstraints(make: ConstraintMaker, elementType: ElementType, view: UIView, in superview: UIView, superviewOrientation: FrameType) {
        
        switch elementType {
        case .frame:
            break
            
        case .text:
            if view is UITextView {
                self.makeConstraintsFor(textView: view as! UITextView, make: make, superview: superview, superviewOrientation: superviewOrientation)
            } else if view is UITextField {
                self.makeConstraintsFor(textField: view as! UITextField, make: make, superview: superview, superviewOrientation: superviewOrientation)
            }
            break
            
        case .dateTimePicker, .placePicker, .select, .contactPicker:
            self.makeConstraintsFor(textField: view as! UITextField, make: make, superview: superview, superviewOrientation: superviewOrientation)
            break
            
        case .button:
            self.makeConstraintsFor(button: view as! UIButton, make: make, superview: superview, superviewOrientation: superviewOrientation)
            break
            
        case .label:
            self.makeConstraintsFor(label: view as! UILabel, make: make, superview: superview, superviewOrientation: superviewOrientation)
            break
            
        case .image:
            self.makeConstraintsFor(imageView: view as! UIImageView, make: make, superview: superview, superviewOrientation: superviewOrientation)
            break
            
        case .switchElement:
            self.makeGenericConstraintsFor(view: view, make: make, superview: superview, superviewOrientation: superviewOrientation)
            break
            
        default:
            break
        }
        
    }
    
    // MARK: - Private
    // general method for frames, text fields/views, pickers
    private static func makeConstraintsFor(view: UIView, make: ConstraintMaker, superview: UIView, superviewOrientation: FrameType) {
        if superviewOrientation == FrameType.vertical {
            
            // make
        } else {
            
        }
    }
    
    private static func makeConstraintsFor(button: UIButton, make: ConstraintMaker, superview: UIView, superviewOrientation: FrameType) {
        if superviewOrientation == FrameType.vertical {
            make.centerX.equalToSuperview()
            
            if superview.subviews.count > 1 {
                let prevSubview = superview.subviews[superview.subviews.count - 2]
                make.top.equalTo(prevSubview.snp.bottom).offset(5)
            } else {
                make.top.equalTo(superview.snp.top).offset(5)
                make.centerX.equalToSuperview()
            }
        } else if superviewOrientation == FrameType.horizontal {
            if superview.subviews.count > 1 {
                let prevSubview = superview.subviews[superview.subviews.count - 2]
                make.top.equalTo(prevSubview.snp.top)
                make.leading.equalTo(prevSubview.snp.trailing).offset(5)
            } else {
                make.top.equalTo(superview.snp.top).offset(5)
                make.leading.equalTo(superview.snp.leading).offset(5)
            }
        } else {
            // If element not nested if frame element then make constraints to view controller's view
            if superview.tag == 100 {
                make.top.equalToSuperview().offset(70)
            } else {
                make.top.equalToSuperview().offset(5)
            }
        }
    }
    
    private static func makeConstraintsFor(label: UILabel, make: ConstraintMaker, superview: UIView, superviewOrientation: FrameType) {
        self.makeGenericConstraintsFor(view: label, make: make, superview: superview, superviewOrientation: superviewOrientation)
        //        make.height.equalTo(UIElementsHeight.label.rawValue)
    }
    
    private static func makeConstraintsFor(textField: UITextField, make: ConstraintMaker, superview: UIView, superviewOrientation: FrameType) {
        self.makeGenericConstraintsFor(view: textField, make: make, superview: superview, superviewOrientation: superviewOrientation)
        //        make.height.equalTo(UIElementsHeight.label.rawValue)
    }
    
    private static func makeConstraintsFor(textView: UITextView, make: ConstraintMaker, superview: UIView, superviewOrientation: FrameType) {
        self.makeGenericConstraintsFor(view: textView, make: make, superview: superview, superviewOrientation: superviewOrientation)
        //        make.height.equalTo(UIElementsHeight.label.rawValue)
    }
    
    private static func makeConstraintsFor(imageView: UIImageView, make: ConstraintMaker, superview: UIView, superviewOrientation: FrameType) {
        self.makeGenericConstraintsFor(view: imageView, make: make, superview: superview, superviewOrientation: superviewOrientation)
        
        //        make.trailing.equalToSuperview().offset(-5)
        //        make.top.equalToSuperview().offset(5)
        //        make.width.equalTo(UIElementsWidth.image.rawValue)
        //        make.height.equalTo(UIElementsWidth.image.rawValue)
    }
    
    private static func makeGenericConstraintsFor(view: UIView, make: ConstraintMaker, superview: UIView, superviewOrientation: FrameType) {
        
        let superviewOrientation = (superviewOrientation == .none) ? .vertical : superviewOrientation
        
        if superviewOrientation == FrameType.vertical {
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
            
            if superview.subviews.count > 1 {
                let prevSubview = superview.subviews[superview.subviews.count - 2]
                make.top.equalTo(prevSubview.snp.bottom).offset(5)
            } else {
                make.top.equalTo(superview.snp.top).offset(5)
                make.centerX.equalToSuperview()
            }
        } else if superviewOrientation == FrameType.horizontal {
            if superview.subviews.count > 1 {
                let prevSubview = superview.subviews[superview.subviews.count - 2]
                make.centerY.equalTo(prevSubview.snp.centerY)
                make.leading.equalTo(prevSubview.snp.trailing).offset(5)
            } else {
                make.top.equalTo(superview.snp.top).offset(5)
                make.leading.equalTo(superview.snp.leading).offset(5)
            }
        } else {
            // If element not nested if frame element then make constraints to view controller's view
            if superview.tag == 100 {
                if superview.subviews.count > 1 {
                    let prevSubview = superview.subviews[superview.subviews.count - 2]
                    if prevSubview.faseElementId == FaseElementsId.navigation.rawValue {
                        make.top.equalToSuperview().offset(70)
                    } else {
                        make.top.equalTo(prevSubview.snp.bottom).offset(5)
                    }
                } else {
                    make.top.equalToSuperview().offset(70)
                }
            } else {
                make.top.equalToSuperview().offset(5)
            }
            
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
        }
    }
}
