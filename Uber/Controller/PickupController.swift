//
//  PickupController.swift
//  Uber
//
//  Created by trungnghia on 5/13/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import MapKit

protocol PickupControllerDelegate: class {
    func didAcceptTrip(_ trip: Trip)
}

class PickupController: UIViewController {
    
    //MARK: - Properties
    weak var delegate: PickupControllerDelegate?
    
    private let mapView = MKMapView()
    
    let trip: Trip
    
    private lazy var circularProgressView: CircularProgressView = {
        let frame = CGRect(x: 0, y: 0, width: 360, height: 360)
        let cp = CircularProgressView(frame: frame)
        
        cp.addSubview(mapView)
        mapView.setDimensions(height: 280, width: 280)
        mapView.layer.cornerRadius = 280 / 2
        mapView.centerX(inView: cp)
        mapView.centerY(inView: cp, constant: 32)
        
        return cp
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    private let pickupLabel: UILabel = {
        let label = UILabel()
        label.text = "Would you like to pickup this passenger ?"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    private let acceptTripButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitle("ACCEPT TRIP", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    init(trip: Trip) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Debug: Trip passenger uid is \(trip.passengerUid ?? "")")
        configureUI()
        configureMapView()
        self.perform(#selector(animateProgress), with: nil, afterDelay: 0.5)
    }
    
    // Hide statusBar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - API
    
    
    //MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .backgroundColor
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                            paddingLeft: 16)
        
        view.addSubview(circularProgressView)
        circularProgressView.setDimensions(height: 360, width: 360)
        circularProgressView.centerX(inView: view)
        circularProgressView.anchor(top: view.topAnchor, paddingTop: 32)
        
        view.addSubview(pickupLabel)
        pickupLabel.centerX(inView: view)
        pickupLabel.anchor(top: circularProgressView.bottomAnchor, paddingTop: 64)
        
        
        view.addSubview(acceptTripButton)
        acceptTripButton.anchor(top: pickupLabel.bottomAnchor, left: view.leftAnchor,
                                right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingRight: 32,
                                height: 50)
        acceptTripButton.layer.cornerRadius = 5
    }
    
    private func configureMapView() {
        let region = MKCoordinateRegion(center: trip.pickupCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)
        mapView.addAnnotationAndSelect(forCoordinate: trip.pickupCoordinates)
    }
    
    //MARK: - Selectors
    @objc func animateProgress() {
        circularProgressView.animatePulsatingLayer()
        circularProgressView.setProgressWithAnimation(duration: 60, value: 0) {
//            DriverService.shared.updateTripState(trip: self.trip, state: .denied) { (error, ref) in
//                if let error = error {
//                    print("Debug: Something wrong with updating trip, \(error.localizedDescription)")
//                    self.showAlert(withMessage: error.localizedDescription)
//                    return
//                }
//                self.dismiss(animated: true, completion: nil)
//            }
        }
    }
    
    @objc func handleDismissal() {
        dismiss(animated: true) {
            DriverService.shared.updateTripState(trip: self.trip, state: .denied) { (error, ref) in
                if let error = error {
                    print("Debug: Something wrong with updating trip, \(error.localizedDescription)")
                    self.showAlert(withMessage: error.localizedDescription)
                    return
                }
            }
        }
    }
    
    @objc func handleAcceptTrip() {
        print("Debug: Accept trip")
        showLoader(true, withText: "Accepting...")
        DriverService.shared.acceptTrip(trip: trip) { (error, ref) in
            self.showLoader(false)
            if let error = error {
                print("Debug: Error accepting trip, \(error.localizedDescription)")
                self.showAlert(withMessage: error.localizedDescription)
                return
            }
            
            self.delegate?.didAcceptTrip(self.trip)
            
        }
        
    }
    
    
}
