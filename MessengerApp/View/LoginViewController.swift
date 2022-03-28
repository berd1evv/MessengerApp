//
//  LoginViewController.swift
//  MessengerApp
//
//  Created by Eldiiar on 27/3/22.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    let phone: UITextField = {
        let text = UITextField()
        text.placeholder = "Enter phone number"
        text.textAlignment = .center
        text.autocorrectionType = .no
        text.autocapitalizationType = .none
        text.returnKeyType = .done
        text.frame = CGRect(x: 80, y: 240, width: 240, height: 60)
        text.clipsToBounds = true
        text.layer.cornerRadius = 5
        text.layer.borderWidth = 1
        text.layer.borderColor = UIColor.lightGray.cgColor
        return text
    }()
    
    let loginButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 80, y: 400, width: 240, height: 60)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .black
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
        
        phone.delegate = self
    
        view.addSubview(phone)
        view.addSubview(loginButton)
    }
    
    @objc func didTapLoginButton() {
        guard let phone = phone.text, !phone.isEmpty else {
            return
        }
        
        
        DatabaseManager.shared.userExists(with: phone) { exists in
            if !phone.isEmpty {
                let number = "\(phone)"
                AuthManager.shared.startAuth(phoneNumber: number) { [weak self] success in
                    guard success else { return }
                    DispatchQueue.main.async {
                        let vc = VerificationViewController()
                        if exists == true {
                            vc.destination = true
                        } else {
                            vc.destination = false
                        }
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapLoginButton()
        return true
    }
}
