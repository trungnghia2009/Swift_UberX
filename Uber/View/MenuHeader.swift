//
//  MenuHeader.swift
//  Uber
//
//  Created by trungnghia on 5/16/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import SDWebImage

class MenuHeader: UIView {
    
    //MARK: - Properties
    private let user: User
    
    private let profileImageView: UIView = {
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
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .systemPurple
        iv.setDimensions(height: 64, width: 64)
        iv.layer.cornerRadius = 32
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
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
    
    private let pickupModeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.text = "Pickup mode"
        return label
    }()
    
    private let pickupSwitch: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = .systemRed
        sw.setOn(true, animated: false)
        sw.isEnabled = false
        sw.addTarget(self, action: #selector(handleSwitch), for: .valueChanged)
        return sw
    }()
    
    private lazy var switchStateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.text = pickupSwitch.isOn ? "On" : "Off"
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
        
        addSubview(pickupModeLabel)
        pickupModeLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, paddingTop: 24, paddingLeft: 12)
        
        addSubview(pickupSwitch)
        pickupSwitch.centerY(inView: pickupModeLabel, leftAnchor: pickupModeLabel.rightAnchor, paddingLeft: 12)
        
        addSubview(switchStateLabel)
        switchStateLabel.centerY(inView: pickupSwitch, leftAnchor: pickupSwitch.rightAnchor, paddingLeft: 12)
        
        pickupSwitch.isEnabled = user.accountType == .driver
        switchStateLabel.text = user.accountType == .passenger ? "Disable" : "On"
        
        if user.profileImageUrl != "" {
            let url = URL(string: user.profileImageUrl)
            imageView.sd_setImage(with: url)
            profileImageView.addSubview(imageView)
            imageView.centerX(inView: profileImageView)
            imageView.centerY(inView: profileImageView)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Helpers
    @objc private func handleSwitch(mySwitch: UISwitch) {
        switchStateLabel.text = mySwitch.isOn ? "On" : "Off"
        
    }
    
}
