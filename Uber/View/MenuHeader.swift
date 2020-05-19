//
//  MenuHeader.swift
//  Uber
//
//  Created by trungnghia on 5/16/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit


class MenuHeader: UIView {
    
    //MARK: - Properties
    private let user: User
    
    private lazy var profileImageView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var initialLabel: UILabel = {
        let label = UILabel()
        label.text = user.firstInitial
        label.font = UIFont.systemFont(ofSize: 40)
        label.textColor = .white
        return label
    }()
    
    private lazy var fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.text = user.fullname
        print("Debug: fullname is \(user.fullname)")
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = user.email
        return label
    }()
    
    
    //MARK: - Lifecycle
    init(user: User, frame: CGRect) {
        self.user = user
        super.init(frame: frame)
        
        backgroundColor = .backgroundColor
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor,
                                paddingTop: 4, paddingLeft: 12,
                                width: 64, height: 64)
        profileImageView.layer.cornerRadius = 32
        
        
        profileImageView.addSubview(initialLabel)
        initialLabel.centerX(inView: profileImageView)
        initialLabel.centerY(inView: profileImageView)
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, emailLabel])
        stack.distribution = .fillEqually
        stack.axis = .vertical
        stack.spacing = 4
        
        addSubview(stack)
        stack.centerY(inView: profileImageView,
                      leftAnchor: profileImageView.rightAnchor, paddingLeft: 12)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
