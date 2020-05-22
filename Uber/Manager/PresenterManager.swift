//
//  PresenterManager.swift
//  Uber
//
//  Created by trungnghia on 5/21/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

class PresenterManager {
    
    static let shared = PresenterManager()
    
    private init() {}
    
    enum VC {
        case containerController
        case loginController
    }
    
    func show(vc: VC) {
        
        var viewController: UIViewController
        
        switch vc {
        case .containerController:
            viewController = ContainerController()
        case .loginController:
            viewController = UINavigationController(rootViewController: LoginController()) // Define UINavigationController for LoginController
        }
        
        if let sceneDelegate =  UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate, let window = sceneDelegate.window  {
            window.rootViewController = viewController
            
            UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
        
    }

    
}
