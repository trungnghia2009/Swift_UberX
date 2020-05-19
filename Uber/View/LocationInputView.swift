//
//  LocationInputView.swift
//  Uber
//
//  Created by trungnghia on 5/11/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

protocol LocationInputViewDelegate: class {
    func dismisLocationInputView()
    func executeSearch(withQuery query: String)
}

class LocationInputView: UIView {

    //MARK: - properties
    weak var delegate: LocationInputViewDelegate?
    var user: User? {
        didSet { configure() }
    }
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "back_button").withRenderingMode(.alwaysOriginal), for: .normal) //arrow icon will come with blue tent color, we want to set it black as original
        button.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        return label
    }()
    
    private let startLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let linkingView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let destinationLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var startingLocationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Current Location"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = .systemGroupedBackground
        tf.layer.cornerRadius = 5
        tf.isEnabled = false
        
        // Add space at the begining of textField
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        tf.leftView = paddingView
        tf.leftViewMode = .always
        
        return tf
    }()
    
    private lazy var destinationLocationTextField: UITextField = {
        let tf = UITextField()
        tf.delegate = self
        tf.placeholder = "Enter a destination..."
        tf.clearButtonMode = .whileEditing
        tf.backgroundColor = .lightGray
        tf.returnKeyType = .search
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.layer.cornerRadius = 5
        
        // Add space at the begining of textField
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        tf.leftView = paddingView
        tf.leftViewMode = .always
        
        return tf
    }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        
        addSubview(backButton)
        backButton.anchor(top: topAnchor, left: leftAnchor, paddingTop: 44, paddingLeft: 12, width: 30, height: 25)
        
        addSubview(titleLabel)
        titleLabel.centerY(inView: backButton)
        titleLabel.centerX(inView: self)
        
        addSubview(startLocationIndicatorView)
        startLocationIndicatorView.anchor(top: backButton.bottomAnchor, left: leftAnchor, paddingTop: 20, paddingLeft: 24, width: 6, height: 6)
        startLocationIndicatorView.layer.cornerRadius = 3
        
        addSubview(linkingView)
        linkingView.anchor(top: startLocationIndicatorView.bottomAnchor, left: leftAnchor, paddingTop: 4, paddingLeft: 26, width: 2, height: 30)
        
        addSubview(destinationLocationIndicatorView)
        destinationLocationIndicatorView.anchor(top: linkingView.bottomAnchor, left: leftAnchor, paddingTop: 4, paddingLeft: 24, width: 6, height: 6)
        
        addSubview(startingLocationTextField)
        startingLocationTextField.centerY(inView: startLocationIndicatorView)
        startingLocationTextField.anchor(left: startLocationIndicatorView.rightAnchor, right: rightAnchor, paddingLeft: 10, paddingRight: 40, height: 30) // 10 = 40 - (24 + 6)
        
        addSubview(destinationLocationTextField)
        destinationLocationTextField.centerY(inView: destinationLocationIndicatorView)
        destinationLocationTextField.anchor(left: destinationLocationIndicatorView.rightAnchor, right: rightAnchor, paddingLeft: 10, paddingRight: 40, height: 30) // 10 = 40 - (24 + 6)

        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    @objc func handleBackTapped() {
        delegate?.dismisLocationInputView()
    }
    
    //MARK: - Helpers
    private func configure() {
        titleLabel.text = user?.fullname
    }
    
}

//MARK: - UITextFieldDelegate
extension LocationInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else { return false }
        delegate?.executeSearch(withQuery: query)
        return true
    }
}
