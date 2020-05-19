//
//  SignupController.swift
//  Uber
//
//  Created by trungnghia on 5/9/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import Firebase
import GeoFire

class RegistrationController: UIViewController {
    
    //MARK: - Properties
    private var profileImage: UIImage?
    private var viewModel = RegistrationViewModel()
    private var location = LocationHandler.shared.locationManager.location
    
    private let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo"), for: .normal)
        button.tintColor = .white
        button.clipsToBounds = true // Fit image to border
        button.setDimensions(height: 150, width: 150)
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        return button
    }()
    
    private lazy var emailContainerView = InputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTextField)
    private let emailTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Email")
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private lazy var passwordContainerView = InputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
    private let passwordTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Password")
        tf.keyboardType = .emailAddress
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private lazy var fullnameContainerView = InputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: fullnameTextField)
    private let fullnameTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Full Name")
        return tf
    }()
    
    
    private lazy var accountTypeContainerView = InputContainerView(image: #imageLiteral(resourceName: "ic_account_box_white_2x"), segmentedControll: accountTypeSegmentedControl)
    private let accountTypeSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Passenger", "Driver"])
        sc.backgroundColor = .white
        sc.tintColor = .white
        sc.selectedSegmentTintColor = .systemBlue
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    
    private let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setHeight(height: 50)
        button.layer.cornerRadius = 5
        button.backgroundColor = .lightGray
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        return button
    }()
    
    private let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [.font: UIFont.systemFont(ofSize: 16),
                                                                                                           .foregroundColor: UIColor.white])
        attributedTitle.append(NSAttributedString(string: "Log In", attributes: [.font: UIFont.boldSystemFont(ofSize: 16),
                                                                                 .foregroundColor: UIColor.systemBlue]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignIn), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNotificationObservers()
    }
    
    //MARK: - Helpers
    private func configureUI() {
        configureGradientLayer(fromColor: UIColor(hexString: "#948E99"), toColor: UIColor(hexString: "#2E1437"))
        dismissKeyboardIfTappingOutside()
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.centerX(inView: view)
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 8)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                   passwordContainerView,
                                                   fullnameContainerView,
                                                   accountTypeContainerView,
                                                   signupButton])
        stack.axis = .vertical
        stack.spacing = 16
        
        view.addSubview(stack)
        stack.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 8)
    }
    
    private func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        fullnameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    
    //MARK: - Selectors
    @objc private func handleSignup() {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let fullname = fullnameTextField.text!
        let accountType = accountTypeSegmentedControl.selectedSegmentIndex
        
        
        showLoader(true, withText: "Uploading image...")
        AuthService.shared.uploadImageToFireStore(withEmail: email, withImage: profileImage) { (error, url) in
            self.showLoader(false)
            if let error = error {
                self.showAlert(withMessage: error.localizedDescription)
                return
            }
            
            let credentials = RegistrationCredentials(email: email, password: password, fullname: fullname, accountType: accountType, profileImageUrl: url)
            self.showLoader(true, withText: "Creating user...")
            AuthService.shared.createUser(withCredentials: credentials) { (error, _) in
                self.showLoader(false)
                if let error = error {
                    self.showAlert(withMessage: error.localizedDescription)
                    return
                }
                
                // configure UI for logging
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                    let window = sceneDelegate.window?.rootViewController as? ContainerController {
                    window.configure()
                }
                
                self.dismiss(animated: true, completion: nil)
                
            }
        }
        
    }
    
    @objc private func handleShowSignIn() {
        print("Debug: Handle show sign in...")
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleSelectPhoto() {
        print("Debug: Handle select photo...")
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func textDidChange(sender: UITextField) {
        switch sender {
        case emailTextField:
            viewModel.email = emailTextField.text
        case passwordTextField:
            viewModel.password = passwordTextField.text
        default:
            viewModel.fullname = fullnameTextField.text
        }
        checkFormStatus()
    }
    
    @objc private func keyboardWillShow() {
        print("Keyboard will show")
        // For iPhone 6s,7,8
        if view.frame.size.height == 667 {
            view.frame.origin.y = -150
        } else {
            view.frame.origin.y = -50
        }
    }
    
    @objc private func keyboardWillHide() {
        print("Keyboard will hide")
        view.frame.origin.y = 0
        
    }
    
    
}

//MARK: - UIImagePickerControllerDelegate
extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        profileImage = image
        plusPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        plusPhotoButton.layer.borderColor = UIColor.white.cgColor
        plusPhotoButton.layer.borderWidth = 3.0
        plusPhotoButton.layer.cornerRadius = 150 / 2
        plusPhotoButton.imageView?.contentMode = .scaleAspectFill
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - AuthenticationControllerProtocol
extension RegistrationController: AuthenticationControllerProtocol {
    func checkFormStatus() {
        if viewModel.formIsValid {
            signupButton.isEnabled = true
            signupButton.backgroundColor = .systemBlue
        } else {
            signupButton.isEnabled = false
            signupButton.backgroundColor = .lightGray
        }
    }
    
    
}


