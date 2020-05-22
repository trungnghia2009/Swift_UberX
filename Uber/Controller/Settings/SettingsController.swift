//
//  SettingsController.swift
//  Uber
//
//  Created by trungnghia on 5/16/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

private let reuseIdentifier = "LocationCell"

enum LocationType: Int, CaseIterable, CustomStringConvertible {
    case home
    case work
    
    var description: String {
        switch self {
        case .home: return "Home"
        case .work: return "Work"
        }
    }
    
    var subtitle: String {
        switch self {
        case .home: return "Add Home"
        case .work: return "Add Work"
        }
    }
}

protocol SettingsControllerDelegate: class {
    func updateUser(_ controller: SettingsController)
}

class SettingsController: UITableViewController {
    
    //MARK: - Properties
    weak var delegate: SettingsControllerDelegate?
    
    var user: User
    private let location = LocationHandler.shared.locationManager.location
    private var userInfoUpdated = false
    
    private lazy var userInfoHeader: UserInfoHeader = {
        let frame = CGRect(x: 0, y: 0,
                           width: view.frame.width, height: 100)
        let view = UserInfoHeader(user: user, frame: frame)
        view.delegate = self
        return view
    }()
    
    private let tableTitle: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundColor
        
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 16)
        title.textColor = .white
        title.text = "Favorites"
        view.addSubview(title)
        title.centerY(inView: view, leftAnchor: view.leftAnchor, paddingLeft: 12)
        
        return view
    }()
    
    
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
        configureNavigationBar()
        self.configureTableView()
    }
    
    //MARK: - Helpers
    private func configureTableView() {
        tableView.backgroundColor = .white
        tableView.rowHeight = 60
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableHeaderView = userInfoHeader
        tableView.tableFooterView = UIView()
    }
    
    private func configureNavigationBar() {
        configureNavigationBar(withTitle: "Settings", prefersLargeTitles: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal),
                                                           style: .plain, target: self, action: #selector(handleDismissal))
    }
    
    func locationText(forType type: LocationType) -> String {

        switch type {
        case .home:
            guard let home = user.homeLocation else { return type.subtitle }
            return home.title + ", " + home.address
        case .work:
            guard let work = user.workLocation else { return type.subtitle }
            return work.title + ", " + work.address
        }
    }
    
    //MARK: - Selectors
    @objc private func handleDismissal() {
        dismiss(animated: true) {
            if self.userInfoUpdated {
                self.delegate?.updateUser(self)
            }
        }
    }
}

//MARK: - UITableViewDataSource/Delegate
extension SettingsController {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableTitle
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationType.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        cell.accessoryType = .detailButton
        
        let locationType = LocationType.allCases[indexPath.row]
        cell.title = locationType.description
        cell.subtitle = locationText(forType: locationType)
        return cell
    }
    
    // Handle
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let locationType = LocationType.allCases[indexPath.row]
        showAlert(withTitle: "Location Info", withMessage: locationText(forType: locationType))
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = LocationType.allCases[indexPath.row]
        guard let location = location else { return }
        
        logger(withDebug: "Tapped \(type.description)..")
        
        let controller = AddLocationController(type: type, location: location)
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        
        
        present(nav, animated: true, completion: nil)
    }
}

//MARK: - AddLocationControllerDelegate
extension SettingsController: AddLocationControllerDelegate {
    func updateLocation(location: [String], type: LocationType) {
        
        PassengerService.shared.saveLocation(location: location, type: type) { (error, ref) in
            if let error = error {
                self.logger(withDebug: "Error saving location, \(error.localizedDescription)")
                return
            }
            self.dismiss(animated: true, completion: nil)
            self.userInfoUpdated = true
            print("Debug: name Location is: \(location[0])")
            
            // save locationString to user object
            switch type {
            case .home:
                self.user.homeLocation = Location(title: location[0], address: location[1])
            case .work:
                self.user.workLocation = Location(title: location[0], address: location[1])
            }
            
            self.tableView.reloadData()
            
        }
    }
    
    
}


//MARK: - UserInfoHeaderDelegate
extension SettingsController: UserInfoHeaderDelegate {
    func editProfileTapped() {
        logger(withDebug: "Navigate to Edit profile view...")
        let controller = EditProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }

}
