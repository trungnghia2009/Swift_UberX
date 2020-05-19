//
//  AuthService.swift
//  Uber
//
//  Created by trungnghia on 5/10/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import Firebase
import GeoFire

struct RegistrationCredentials {
    let email: String
    let password: String
    let fullname: String
    let accountType: Int
    var profileImageUrl: String?
}

struct AuthService {
    
    static let shared = AuthService()
    
    private init() {}
    
    let auth = Auth.auth()
    
    func loginUser(withEmail email: String, password: String, completion: AuthDataResultCallback?) {
        auth.signIn(withEmail: email, password: password, completion: completion)
    }
    
    func uploadImageToFireStore(withEmail email: String, withImage image: UIImage?, completion: @escaping (Error?, String?) -> Void) {
        var profileImageUrl: String?
        let error: Error? = nil
        if let image = image?.resizeWithWidth(width: 600.0) {
            let imageData = image.jpegData(compressionQuality: 0.8)!
            let fileName = email + "_avatar"
            
            let ref = Storage.storage().reference(withPath: "/profile_images/\(fileName)")
            
            ref.putData(imageData, metadata: nil) { (meta, error) in
                if let error = error {
                    completion(error, profileImageUrl)
                    return
                }
                
                ref.downloadURL { (url, error) in
                    if let error = error {
                        completion(error, profileImageUrl)
                        return
                    }
                    
                    profileImageUrl = url?.absoluteString
                    completion(error, profileImageUrl)
                }
            }
        } else {
            completion(error, profileImageUrl)
        }
    }
    
    
    func createUser(withCredentials credentials: RegistrationCredentials, completion: @escaping (Error?, DatabaseReference?) -> Void) {
        let databaseReference: DatabaseReference? = nil
        Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { (result, error) in
            if let error = error {
                completion(error, databaseReference)
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            let data = ["email": credentials.email,
                        "fullname": credentials.fullname,
                        "accountType": credentials.accountType,
                        "profileImageUrl": credentials.profileImageUrl ?? ""] as [String : Any]
            
            // Create location and user data if accoutnType = 1 <Driver>
            if credentials.accountType == 1 {
                let geoFire = GeoFire(firebaseRef: kREF_DRIVER_LOCATIONS)
                guard let location = LocationHandler.shared.locationManager.location else { return }
                
                geoFire.setLocation(location, forKey: uid) { (error) in
                    kREF_USERS.child(uid).updateChildValues(data) { (error, data) in
                        if let error = error {
                            completion(error, databaseReference)
                            return
                        }
                        completion(error, data)
                        
                    }
                }
            } else {
                kREF_USERS.child(uid).updateChildValues(data) { (error, data) in
                    if let error = error {
                        completion(error, databaseReference)
                        return
                    }
                    completion(error, data)
                    
                }
            }
            
            
        }
        
    }
}

private extension UIImage {
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
