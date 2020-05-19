//
//  LocationCell.swift
//  Uber
//
//  Created by trungnghia on 5/11/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import MapKit

class LocationCell: UITableViewCell {

    //MARK: - Properties
    var placemark: MKPlacemark? {
        didSet {
            titleLabel.text = placemark?.name
            addressLabel.text = placemark?.title
        }
    }
    
    // for savedPlacemark
    var savedTitle: String? {
        didSet {
            titleLabel.text = savedTitle
        }
    }
    var savedPlacemarkAdress: MKPlacemark? {
        didSet {
            addressLabel.text = savedPlacemarkAdress?.title
        }
    }
    
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var subtitle: String? {
        didSet {
            addressLabel.text = subtitle
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    
    
    //MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 4
        
        addSubview(stack)
        stack.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        stack.anchor(right: rightAnchor, paddingRight: 48)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    private func configure() {
        titleLabel.text = placemark?.name
        addressLabel.text = placemark?.title
    }
    
    
    
}
