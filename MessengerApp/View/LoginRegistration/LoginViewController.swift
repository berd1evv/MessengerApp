//
//  LoginViewController.swift
//  MessengerApp
//
//  Created by Eldiiar on 27/3/22.
//

import UIKit
import Firebase
import JGProgressHUD

class LoginViewController: UIViewController {
    
    let spinner = JGProgressHUD(style: .dark)
    
    let phone: UITextField = {
        let text = UITextField()
        text.placeholder = "Enter phone number"
        text.textAlignment = .center
        text.autocorrectionType = .no
        text.autocapitalizationType = .none
        text.returnKeyType = .done
        text.keyboardType = .phonePad
        text.translatesAutoresizingMaskIntoConstraints = false
        text.clipsToBounds = true
        text.layer.cornerRadius = 5
        text.layer.borderWidth = 1
        text.layer.borderColor = UIColor.lightGray.cgColor
        return text
    }()
    
    let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .black
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
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
        
        setUpConstraints()
    }
    
    @objc func didTapLoginButton() {
        guard let phone = phone.text, !phone.isEmpty else {
            return
        }
        
        let phoneNumber = phone.replacingOccurrences(of: " ", with: "")
        
        UserDefaults.standard.set(phoneNumber, forKey: "phone")
        spinner.show(in: view)
        
        DatabaseManager.shared.userExistsFirestore(with: phoneNumber) { exists in
            if !phone.isEmpty {
                let number = "\(phoneNumber)"
                AuthManager.shared.startAuth(phoneNumber: number) { [weak self] success in
                    guard success else { return }
                    DispatchQueue.main.async {
                        self?.spinner.dismiss()
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
    
    func setUpConstraints() {
        
        phone.snp.makeConstraints { make in
            make.bottom.equalTo(loginButton.snp.top).offset(-50)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().dividedBy(1.5)
            make.height.equalTo(60)
        }
        
        loginButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().dividedBy(1.5)
            make.height.equalTo(60)
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapLoginButton()
        return true
    }
}
