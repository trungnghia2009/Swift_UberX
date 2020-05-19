//
//  ContainerView.swift
//  FireChat
//
//  Created by trungnghia on 5/4/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

class InputContainerView: UIView {
    
    init(image: UIImage?, textField: UITextField? = nil, showButton: UIButton? = nil, segmentedControll: UISegmentedControl? = nil) {
        super.init(frame: .zero)
        
        if let _ = segmentedControll {
            setHeight(height: 80)
        } else {
            setHeight(height: 50)
        }
        
        
        let iv = UIImageView()
        iv.image = image
        iv.tintColor = .white
        iv.alpha = 0.87
        addSubview(iv)
        
        
        if let sc = segmentedControll {
            iv.anchor(top: self.topAnchor, left: self.leftAnchor, paddingTop: 0, paddingLeft: 8, width: 24, height: 24)
            
            addSubview(sc)
            sc.centerY(inView: self)
            sc.anchor(left: self.leftAnchor, right: self.rightAnchor, paddingLeft: 8, paddingRight: 0)
        } else {
            iv.centerY(inView: self)
            iv.anchor(left: self.leftAnchor, paddingLeft: 8)
            iv.setDimensions(height: 24, width: 24)
        }
        
        if let button = showButton {
            addSubview(button)
            button.centerY(inView: self)
            button.anchor(right: self.rightAnchor)
            button.setDimensions(height: 15, width: 20)
            if let textField = textField {
                addSubview(textField)
                textField.centerY(inView: self)
                textField.anchor(left: iv.rightAnchor, right: button.leftAnchor, paddingLeft: 10, paddingRight: 10)
            }
        } else {
            if let textField = textField {
                addSubview(textField)
                textField.centerY(inView: self)
                textField.anchor(left: iv.rightAnchor, right: self.rightAnchor, paddingLeft: 8)
            }
        }
        
        let dividerView = UIView()
        dividerView.backgroundColor = .white
        addSubview(dividerView)
        dividerView.anchor(left: self.leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingLeft: 8, height: 0.75)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

