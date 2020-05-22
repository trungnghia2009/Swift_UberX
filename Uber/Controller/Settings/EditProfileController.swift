//
//  EditProfileController.swift
//  Uber
//
//  Created by trungnghia on 5/21/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

class EditProfileController: UIViewController {
    
    //MARK: - Properties
    let user: User
    
    //MARK: - Lifecycle
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar(withTitle: "Edit Profile", prefersLargeTitles: true)
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logger(withDebug: "Email is: \(user.email)")
        logger(withDebug: "Full name is: \(user.fullname)")
        logger(withDebug: "Image url is: \(user.profileImageUrl)")
    }
    
    
    //MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        
    }
    
    //MARK: - Selectors
    
}
