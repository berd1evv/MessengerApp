//
//  DatabaseManager.swift
//  MessengerApp
//
//  Created by Eldiiar on 28/3/22.
//

import Foundation
import Firebase

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    let database = Database.database().reference()
    
    func userExists(with phone: String, completion: @escaping (Bool) -> ()) {
        database.child(phone).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? [String: Any] != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func insertUser(with user: User) {
        database.child(user.phone).setValue([
            "first_name" : user.firstName,
            "last_name" : user.lastName,
            "email" : user.email
        ])
    }
}
