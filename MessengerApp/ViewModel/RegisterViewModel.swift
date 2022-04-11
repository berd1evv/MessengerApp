//
//  LoginViewModel.swift
//  MessengerApp
//
//  Created by Eldiiar on 11/4/22.
//

import Foundation
import UIKit

protocol RegisterViewModelProtocol {
    func insertUser(user: UserModel, imageView: UIImageView)
}

class RegisterViewModel: RegisterViewModelProtocol {
    func insertUser(user: UserModel, imageView: UIImageView) {
        DatabaseManager.shared.insertUserFirestore(with: user) { [weak self] success in
            if success {
                guard let image = imageView.image, let data = image.pngData() else {
                    return
                }
                let fileName = user.profilePictureFileName
                self?.uploadProfilePicture(data: data, fileName: fileName)
            }
        }
    }
    
    func uploadProfilePicture(data: Data, fileName: String) {
        StorageManger.shared.uploadProfilePicture(with: data, fileName: fileName) { result in
            switch result {
            case .success(let downloadURL):
                UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
            case .failure(_):
                print("Storage manager error")
            }
        }
    }
}
