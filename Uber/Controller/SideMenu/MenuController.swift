//
//  MenuController.swift
//  Uber
//
//  Created by trungnghia on 5/16/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MenuCell"

enum MenuOptions: Int, CaseIterable, CustomStringConvertible {
    case yourTrips
    case settings
    case logout
    
    var description: String {
        switch self {
        case .yourTrips: return "Your Trips"
        case .settings: return "Settings"
        case .logout: return "Log Out"
        }
    }
}

protocol MenuControllerDelegate: class {
    func didSelect(option: MenuOptions)
}

class MenuController: UITableViewController {
    
    //MARK: - Properties
    private let user: User
    weak var delegate: MenuControllerDelegate?
    
    
    private lazy var menuHeader: MenuHeader = {
        let frame = CGRect(x: 0, y: 0,
                           width: view.frame.width - 80, height: 140)
        let view = MenuHeader(user: user, frame: frame)
        logger(withDebug: "in menuHeader with email \(user.email)..")
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
        view.backgroundColor = .white
        configureTableView()
        logger(withDebug: "viewDidLoad in MenuController...")
    }
    
    
    //MARK: - Helpers
    private func configureTableView() {
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.rowHeight = 60
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        logger(withDebug: "in configureTableView...")
        tableView.tableHeaderView = menuHeader
    }
    
    
    //MARK: - Selectors
    
    
}


extension MenuController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuOptions.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = MenuOptions.allCases[indexPath.row].description
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = MenuOptions.allCases[indexPath.row]
        delegate?.didSelect(option: option)
    }
}