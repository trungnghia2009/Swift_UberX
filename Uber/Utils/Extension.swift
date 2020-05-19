//
//  Extension.swift
//  Uber
//
//  Created by trungnghia on 5/9/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import JGProgressHUD
import MapKit

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
    }
    
    static let backgroundColor = UIColor.rgb(red: 25, green: 25, blue: 25)
    static let mainBlueTint = UIColor.rgb(red: 17, green: 154, blue: 237)
    static let outlineStrokeColor = UIColor.rgb(red: 234, green: 46, blue: 111)
    static let trackStrokeColor = UIColor.rgb(red: 56, green: 25, blue: 49)
    static let pulsatingFillColor = UIColor.rgb(red: 86, green: 30, blue: 63)
}

extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func centerX(inView view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil,
                 paddingLeft: CGFloat = 0, constant: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        
        if let left = leftAnchor {
            anchor(left: left, paddingLeft: paddingLeft)
        }
    }
    
    func setDimensions(height: CGFloat, width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func setHeight(height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func setWidth(width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func configureGradientLayer() {
        let gradient =  CAGradientLayer()
        gradient.colors = [UIColor.systemPurple.cgColor, UIColor.systemPink.cgColor]
        gradient.locations = [0, 1]
        layer.addSublayer(gradient)
        gradient.frame = frame //Fit gradient to view
    }
    
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.45
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        layer.masksToBounds = false
    }
}

extension UIViewController {
    static let hud = JGProgressHUD(style: .extraLight)
    
    func configureGradientLayer(fromColor start: UIColor, toColor end: UIColor) {
        let gradient =  CAGradientLayer()
        gradient.colors = [start.cgColor, end.cgColor]
        gradient.locations = [0, 1]
        view.layer.addSublayer(gradient)
        gradient.frame = view.frame //Fit gradient to view
    }
    
    func showLoader(_ show: Bool, withText text: String = "Loading...") {
        view.endEditing(true)
        if show {
             UIViewController.hud.textLabel.text = text
            UIViewController.hud.show(in: view)
        } else {
            UIViewController.hud.dismiss()
        }
        
    }
    
    func showError(withText text: String) {
        let hud = JGProgressHUD(style: .extraLight)
        hud.textLabel.text = text
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.show(in: view)
        hud.dismiss(afterDelay: 3.0)
    }
    
    func showAlert(withTitle title: String? = nil, withMessage message: String) {
        var alertTitle: String
        if let title = title {
            alertTitle = title
        } else {
            alertTitle = "Error"
        }
        
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func configureNavigationBar(withTitle title: String, prefersLargeTitles: Bool) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundColor = .backgroundColor
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.title = title
        
        navigationController?.navigationBar.overrideUserInterfaceStyle = .dark //Make the status bar white in color
    }
    
    func dismissKeyboardIfTappingOutside() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(false)
    }
    
    func shouldPresentLoadingView(_ present: Bool, message: String? = nil) {
        if present {
            let loadingView = UIView()
            loadingView.frame = self.view.frame
            loadingView.backgroundColor = .black
            loadingView.alpha = 0
            loadingView.tag = 1
            
            let indicator = UIActivityIndicatorView()
            indicator.style = .large
            indicator.color = .white
            indicator.center = view.center
            
            let label = UILabel()
            label.text = message
            label.font = UIFont.systemFont(ofSize: 20)
            label.textColor = .white
            label.textAlignment = .center
            label.alpha = 0.87
            
            view.addSubview(loadingView)
            loadingView.addSubview(indicator)
            loadingView.addSubview(label)
            
            label.centerX(inView: view)
            label.anchor(top: indicator.bottomAnchor, paddingTop: 32)
            
            indicator.startAnimating()
            
            UIView.animate(withDuration: 0.3) {
                loadingView.alpha = 0.7
            }
        } else {
            view.subviews.forEach { (subview) in
                if subview.tag == 1 {
                    UIView.animate(withDuration: 0.3, animations: {
                        subview.alpha = 0
                    }, completion: { _ in
                        subview.removeFromSuperview()
                    })
                }
            }
        }
        
    }
    
    func logger(withDebug debug: String) {
        print("Debug: \(debug)")
    }
    
}

extension UIColor {
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
}

extension MKPlacemark {
    var address: String? {
        get {
            guard let subThoroughfare = subThoroughfare else { return nil }
            guard let thoroughfare = thoroughfare else { return nil }
            guard let locality = locality else { return nil }
            guard let adminArea = administrativeArea else { return nil }
            
            return "\(subThoroughfare) \(thoroughfare), \(locality), \(adminArea) "
        }
    }
}

extension MKMapView {
    func zoomToFit(annotations: [MKAnnotation]) {
        var zoomRect = MKMapRect.null
        
        annotations.forEach { (annotation) in
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y,
                                      width: 0.01, height: 0.01)
            zoomRect = zoomRect.union(pointRect)
        }
        
        let insets = UIEdgeInsets(top: 75, left: 75, bottom: 350, right: 75)
        setVisibleMapRect(zoomRect, edgePadding: insets, animated: true)
    }
    
    func addAnnotationAndSelect(forCoordinate coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        addAnnotation(annotation)
        selectAnnotation(annotation, animated: true) // Highlight annotation
    }
}

