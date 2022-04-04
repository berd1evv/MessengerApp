//
//  User.swift
//  MessengerApp
//
//  Created by Eldiiar on 28/3/22.
//

import Foundation

struct UserModel {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    
    var profilePictureFileName: String {
        return "\(phone)_profile_picture.png"
    }
}
