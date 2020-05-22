//
//  AddLocationController.swift
//  Uber
//
//  Created by trungnghia on 5/17/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import MapKit

private let reuseIdentifier = "Cell"

protocol AddLocationControllerDelegate: class {
    func updateLocation(location: [String], type: LocationType)
}

class AddLocationController: UITableViewController {
    
    //MARK: - Properties
    weak var delegate: AddLocationControllerDelegate?
    
    private let searchBar = UISearchBar()
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]() {
        didSet { tableView.reloadData() }
    }
    
    private let type: LocationType
    private let location: CLLocation
    
    //MARK: - Lifecycle
    init(type: LocationType, location: CLLocation) {
        self.type = type
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar(withTitle: type.subtitle, prefersLargeTitles: true)
        configureTableView()
        configureSearchBar()
        configureSearchCompleter()
        
        logger(withDebug: "Type is \(type.description)")
        logger(withDebug: "Coordinate is \(location.coordinate)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder() // Auto-focus in searchBar field
    }
    
    
    //MARK: - Helpers
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60
        
        tableView.addShadow()
    }
    
    func configureSearchBar() {
        searchBar.sizeToFit() // put search bar inside of the navigation controller size
        searchBar.delegate = self
        searchBar.placeholder = "Search..."
        searchBar.returnKeyType = .done
        navigationItem.titleView = searchBar
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_clear_white_36pt_2x"), style: .plain, target: self, action: #selector(handleDismissal))
    }
    
    func configureSearchCompleter() {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        searchCompleter.region = region
        searchCompleter.delegate = self
        
    }
    
    //MARK: - Selectors
    @objc private func handleDismissal() {
        dismiss(animated: true, completion: nil)
    }
}


//MARK: - UITableViewDataSource/Delegate
extension AddLocationController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        let result = searchResults[indexPath.row]
        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.subtitle
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = searchResults[indexPath.row]
        let title = result.title
        let address = result.subtitle
        let locations: [String] = [title, address]
        
        delegate?.updateLocation(location: locations, type: type)
    }
    
}


//MARK: - UISearchBarDelegate
extension AddLocationController: UISearchBarDelegate {
    
    // Run whenever text did change in searchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(false)
        logger(withDebug: "Click Done...")
    }
}

//MARK: - MKLocalSearchCompleterDelegate
extension AddLocationController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }
}
