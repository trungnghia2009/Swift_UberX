//
//  ContainerController.swift
//  Uber
//
//  Created by trungnghia on 5/16/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import Firebase



class ContainerController: UIViewController {
    
    //MARK: - Properties
    private var homeController = HomeController()
    private var menuController: MenuController!
   
    private var blackView = UIView()
    private var isHideStatusBar = false
    
    private var user: User? {
        didSet {
            guard let user = user else { return }
            logger(withDebug: "Email in user is \(user.email)")
            homeController.user = user
            configureMenuController(withUser: user)
        }
    }
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        return isHideStatusBar
    }
    
    // configure animation for statusBar
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    
    //MARK: - API
    private func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            print("Debug: Not login")
            //presentLoginScreen()
            PresenterManager.shared.show(vc: .loginController)
        } else {
            print("Debug: Welcome \(Auth.auth().currentUser!.email!)")
            configure()
        }
    }
    
    private func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
//        homeController.showLoader(true, withText: "Loading user...")
        Service.shared.fetchUserData(uid: currentUid) { (user) in
//            self.homeController.showLoader(false)
            self.user = user
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            //presentLoginScreen()
            PresenterManager.shared.show(vc: .loginController)
        } catch {
            showAlert(withMessage: error.localizedDescription)
        }
    }
    
    //MARK: - Helpers
    func configure() {
        view.backgroundColor = .backgroundColor
        fetchUserData()
        configureHomeController()
    }
    
    
    private func configureHomeController() {
        addChild(homeController)
        homeController.didMove(toParent: self)
        view.addSubview(homeController.view)
        homeController.delegate = self
        
    }
    
    private func configureMenuController(withUser user: User) {
        menuController = MenuController(user: user)
        addChild(menuController)
        menuController.didMove(toParent: self)
        view.insertSubview(menuController.view, at: 0)
        menuController.delegate = self
        configureBlackView()
    }
    
    private func animateMenu(shouldExpand: Bool, completion: ((Bool) -> Void)? = nil) {
        if shouldExpand {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeController.view.frame.origin.x = self.view.frame.width - 80
                self.blackView.alpha = 1
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeController.view.frame.origin.x = 0
                self.blackView.alpha = 0
            }, completion: completion)
        }
        
        animateStatusBar()
    }
    
    private func presentLoginScreen() {
        DispatchQueue.main.async {
            let nav = UINavigationController(rootViewController: LoginController())
            nav.modalPresentationStyle = .fullScreen
            if #available(iOS 13.0, *) {
                print("Debug: is iOS 13..")
                nav.isModalInPresentation = true
            }
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    private func configureBlackView() {
        blackView.frame = view.bounds
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.alpha = 0
        homeController.view.addSubview(blackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tap)
    }
    
    private func animateStatusBar() {
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    private func present(controller: UIViewController) {
        let controller = UINavigationController(rootViewController: controller)
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    
    
    //MARK: - Selectors
    @objc private func dismissMenu() {
        print("Debug: handle dismissMenu....")
        isHideStatusBar = false
        animateMenu(shouldExpand: false)
    }
    
}


//MARK: - HomeControllerDelegate
extension ContainerController: HomeControllerDelegate {
    func updateMenuHeader(user: User) {
        
    }
    
    
    func handleMenuToggle() {
        isHideStatusBar = true
        animateMenu(shouldExpand: true)
    }
}

//MARK: - MenuControllerDelegate
extension ContainerController: MenuControllerDelegate {
    func didSelect(option: MenuOptions) {
        isHideStatusBar = false
        animateMenu(shouldExpand: false) { (_) in
            switch option {
                    
            case .yourTrips:
                break
                
            case .settings:
                guard let user = self.user else { return }
                let settingController = SettingsController(user: user)
                settingController.delegate = self
                self.present(controller: settingController)
            
            case .logout:
                let alertController = UIAlertController(title: nil, message: "Are you sure you want to log out ?", preferredStyle: .actionSheet)
                
                alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
                    self.signOut()
                }))
                alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            
            }
            }
        }
}

//MARK: - SettingsControllerDelegate
extension ContainerController: SettingsControllerDelegate {
    func updateUser(_ controller: SettingsController) {
        self.user = controller.user
    }
    
    
}
