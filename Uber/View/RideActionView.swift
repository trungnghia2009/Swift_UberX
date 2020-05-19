//
//  RideActionView.swift
//  Uber
//
//  Created by trungnghia on 5/13/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import MapKit

protocol RideActionViewDelegate: class {
    func dropDownRideActionView()
    func uploadTrip(_ view: RideActionView)
    func cancelTrip()
    func pickupPassenger()
    func dropOffPassenger()
}

enum RideActionViewConfiguration {
    case requestRide
    case tripAccepted
    case driverArrived
    case pickupPassenger
    case tripInProgress
    case endTrip
    
    init() {
        self = .requestRide
    }
}

enum ButtonAction: CustomStringConvertible {
    case requestRide
    case cancel
    case getDirections
    case pickup
    case dropOff
    
    var description: String {
        switch self {
            
        case .requestRide:
            return "CONFIRM UBERX"
        case .cancel:
            return "CANCEL RIDE"
        case .getDirections:
            return "GET DIRECTIONS"
        case .pickup:
            return "PICKUP PASSENGER"
        case .dropOff:
            return "DROP OFF PASSENGER"
        }
    }
    
    init() {
        self = .requestRide
    }
}

class RideActionView: UIView {

    //MARK: - Properties
    weak var delegate: RideActionViewDelegate?
    var viewIsDown = false
    
    var destination: MKPlacemark? {
        didSet { configure() }
    }
    
    //config enum
    var config = RideActionViewConfiguration() {
        didSet { configureUI(withConfig: config) }
    }
    
    var buttonAction = ButtonAction()
    
    var user: User?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
        view.addSubview(infoViewLabel)
        infoViewLabel.centerX(inView: view)
        infoViewLabel.centerY(inView: view)
        return view
    }()
    
    private let infoViewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.text = "X"
        return label
    }()
    
    private let uberInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Uber X"
        label.textAlignment = .center
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("CONFIRM UBERX", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleAction), for: .touchUpInside)
        return button
    }()
    
    private let dropDownButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "drop-down-80").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDropDown), for: .touchUpInside)
        return button
    }()
    
    
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 12, paddingRight: 12)
        
        addSubview(infoView)
        infoView.centerX(inView: self)
        infoView.anchor(top: stack.bottomAnchor, paddingTop: 16, width: 60, height: 60)
        infoView.layer.cornerRadius = 30
        
        addSubview(uberInfoLabel)
        uberInfoLabel.centerX(inView: self)
        uberInfoLabel.anchor(top: infoView.bottomAnchor, paddingTop: 8)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        addSubview(separatorView)
        separatorView.anchor(top: uberInfoLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 4, height: 0.75)
        
        addSubview(actionButton)
        actionButton.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingLeft: 12, paddingBottom: 0, paddingRight: 12)
        actionButton.setHeight(height: 50)
        
        addSubview(dropDownButton)
        dropDownButton.anchor(top: topAnchor, right: rightAnchor, paddingTop: 8, paddingRight: 8, width: 30, height: 30)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Helpers
    private func configure() {
        titleLabel.text = destination?.name
        addressLabel.text = destination?.title
    }
    
    private func configureUI(withConfig config: RideActionViewConfiguration) {
        switch config {
            
        case .requestRide:
            buttonAction = .requestRide
            actionButton.setTitle(buttonAction.description, for: .normal)
            infoViewLabel.text = "X"
            uberInfoLabel.text = "Uber X"
            actionButton.isEnabled = true
            
        case .tripAccepted:
            guard let user = user else { return }
            if user.accountType == .passenger {
                titleLabel.text = "En Route to Passenger"
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal)
            } else {
                titleLabel.text = "Driver En Route"
                buttonAction = .cancel
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            
            infoViewLabel.text = String(user.fullname.first ?? "X")
            uberInfoLabel.text = user.fullname
            
        case .driverArrived:
            guard let user = user else { return }
            
            if user.accountType == .driver {
                titleLabel.text = "Driver Has Arrived"
                addressLabel.text = "Please meet driver at pickup location"
            }
            
        case .pickupPassenger:
            titleLabel.text = "Arrived At Passenger Location"
            buttonAction = .pickup
            actionButton.setTitle(buttonAction.description, for: .normal)
            
        case .tripInProgress:
            guard let user = user else { return }
            
            if user.accountType == .driver {
                actionButton.setTitle("TRIP IN PROGRESS", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            
            titleLabel.text = "En Route To Destination"
            
        case .endTrip:
            guard let user = user else { return }
            
            if user.accountType == .driver {
                actionButton.setTitle("ARRIVED AT DESTINATION", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .dropOff
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            
            titleLabel.text = "Arrived at Destination"
        }
    }
    
    
    
    //MARK: - Selectors
    @objc func handleAction() {
        
        
        switch buttonAction {
        case .requestRide:
            print("Debug: Handle upload trip...")
            delegate?.uploadTrip(self)
        case .cancel:
            print("Debug: Handle cancel trip...")
            delegate?.cancelTrip()
        case .getDirections:
            print("Debug: Handle get direction...")
        case .pickup:
            print("Debug: Handle pickup...")
            delegate?.pickupPassenger()
        case .dropOff:
            print("Debug: Handle drop off...")
            delegate?.dropOffPassenger()
            
        }
    }
    
    @objc func handleDropDown() {
        delegate?.dropDownRideActionView()
    }
}
