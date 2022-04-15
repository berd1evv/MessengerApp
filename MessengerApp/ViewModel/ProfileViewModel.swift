//
//  ProfileViewModel.swift
//  MessengerApp
//
//  Created by Eldiiar on 11/4/22.
//

import Foundation
import UIKit

protocol ProfileViewModelProtocol {
    var data: [String] {get}
    var vc: RegisterViewController {get set}
    func setUpProfilePicture(image: UIImageView)
    func setAccountPicture()
}

class ProfileViewModel: ProfileViewModelProtocol {
    let data = ["Account", "Log out"]
    var vc = RegisterViewController()
    
    func setUpProfilePicture(image: UIImageView) {
        let phone = UserDefaults.standard.string(forKey: "phone") ?? ""
        let fileName = phone + "_profile_picture.png"
        let path = "images/" + fileName
        
        StorageManger.shared.downloadURL(for: path) { result in
            switch result {
            case .success(let url):
                image.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print("Failed to get download: \(error)")
            }
        }
    }
    
    func setAccountPicture() {
        let firstName = UserDefaults.standard.string(forKey: "firstName")
        let lastName = UserDefaults.standard.string(forKey: "lastName")
        let email = UserDefaults.standard.string(forKey: "email")
        let phone = UserDefaults.standard.string(forKey: "phone") ?? ""
        
        let fileName = phone + "_profile_picture.png"
        let path = "images/" + fileName
        
        StorageManger.shared.downloadURL(for: path) { [weak self] result in
            switch result {
            case .success(let url):
                self?.vc.imageView.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print("Failed to get download: \(error)")
            }
        }
        
        vc.firstName.text = firstName
        vc.lastName.text = lastName
        vc.email.text = email
        vc.registrationButton.setTitle("Save", for: .normal)
    }
}
