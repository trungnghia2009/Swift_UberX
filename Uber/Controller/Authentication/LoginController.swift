//
//  LoginController.swift
//  Uber
//
//  Created by trungnghia on 5/9/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import Firebase

protocol AuthenticationControllerProtocol {
    func checkFormStatus()
}

class LoginController: UIViewController {
    
    //MARK: - Properties
    private var toggleFlag = false
    private var viewModel = LoginViewModel()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = .white
        return label
    }()
    
    private lazy var emailContainerView = InputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTextField)
    private let emailTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Email")
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private lazy var passwordContainerView = InputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField, showButton: showButton)
    private let passwordTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let showButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(toggleShowPassword), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setHeight(height: 50)
        button.layer.cornerRadius = 5
        button.backgroundColor = .lightGray
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    private let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [.font: UIFont.systemFont(ofSize: 16),
                                                                                                         .foregroundColor: UIColor.white])
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [.font: UIFont.boldSystemFont(ofSize: 16),
                                                                                  .foregroundColor: UIColor.systemBlue]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNotificationObservers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toggleFlag = false
        showButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        passwordTextField.isSecureTextEntry = true
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // Change status bar to white
    }
    
    //MARK: - Helpers
    private func configureUI() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black //Make the status bar white in color, it does work if using large title !!!
        
        configureGradientLayer(fromColor: UIColor(hexString: "#948E99"), toColor: UIColor(hexString: "#2E1437"))
        dismissKeyboardIfTappingOutside()
        
        view.addSubview(titleLabel)
        titleLabel.centerX(inView: view)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 8)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                   passwordContainerView,
                                                   loginButton])
        stack.axis = .vertical
        stack.spacing = 16
        
        view.addSubview(stack)
        stack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 8)
    }
    
    private func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    //MARK: - Selectors
    @objc func handleLogin() {
        showLoader(true)
        AuthService.shared.loginUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
            self.showLoader(false)
            if let error = error {
                self.showAlert(withMessage: error.localizedDescription)
                return
            }
            
            // configure UI for signup
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                let window = sceneDelegate.window?.rootViewController as? ContainerController {
                window.configure()
            }
            
            
            print("Debug: handle login sucessful here...")
            //self.dismiss(animated: true, completion: nil)
            PresenterManager.shared.show(vc: .containerController)
            
        }
    }
    
    @objc private func handleShowSignUp() {
        print("Debug: Handle signup...")
        let controller = RegistrationController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func toggleShowPassword() {
        passwordTextField.isSecureTextEntry.toggle()
        let systemImageName: String = toggleFlag ? "eye.fill" : "eye.slash.fill"
        showButton.setImage(UIImage(systemName: systemImageName), for: .normal)
        toggleFlag.toggle()
    }
    
    @objc private func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else {
            viewModel.password = sender.text
        }
        checkFormStatus()
    }
    
    
    
}

extension LoginController: AuthenticationControllerProtocol {
    func checkFormStatus() {
        if viewModel.formIsValid {
            loginButton.isEnabled = true
            loginButton.backgroundColor = .systemBlue
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = .lightGray
        }
    }
    
    
    
    
    
}
