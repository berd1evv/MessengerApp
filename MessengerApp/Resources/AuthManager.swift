//
//  AuthManager.swift
//  MessengerApp
//
//  Created by Eldiiar on 28/3/22.
//

import Foundation
import Firebase

class AuthManager {
    static let shared = AuthManager()
    
    let auth = Auth.auth()
    
    var verificationId: String?
    
    func startAuth(phoneNumber: String, completion: @escaping (Bool) -> ()) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationId, error in
            guard let verificationId = verificationId, error == nil else {
                completion(false)
                return
            }
            self?.verificationId = verificationId
            completion(true)
        }
    }
    
    func verifyCode(code: String, completion: @escaping (Bool) -> ()) {
        guard let verificationId = verificationId else {
            completion(false)
            return
        }
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: code)
        auth.signIn(with: credential) { result, error in
            guard result != nil, error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
}
