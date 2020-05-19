//
//  File.swift
//  FireChat
//
//  Created by trungnghia on 5/4/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    
    init(placeholder: String) {
        super.init(frame: .zero)
        borderStyle = .none
        font = UIFont.systemFont(ofSize: 16)
        keyboardAppearance = .dark
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor.lightGray])
        textColor = .white
        clearButtonMode = .whileEditing
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
