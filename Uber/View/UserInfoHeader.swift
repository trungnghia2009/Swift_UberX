//
//  UserInfoHeader.swift
//  Uber
//
//  Created by trungnghia on 5/17/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

class UserInfoHeader: UIView {
    
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
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.text = user.fullname
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
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        profileImageView.setDimensions(height: 64, width: 64)
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
