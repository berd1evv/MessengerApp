//
//  LoginViewController.swift
//  MessengerApp
//
//  Created by Eldiiar on 27/3/22.
//

import UIKit
import Firebase
import JGProgressHUD
import SnapKit

class LoginViewController: UIViewController {
    
    let spinner = JGProgressHUD(style: .dark)
    
    private var phone: UITextField = {
        let text = UITextField()
        text.placeholder = "Enter phone number ex: +996XXXXXXXXX"
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
    
    private var alertLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var loginButton: UIButton = {
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
        view.addSubview(alertLabel)
        view.addSubview(loginButton)
        
        setUpConstraints()
    }
    
    @objc func didTapLoginButton() {
        guard let phone = phone.text, !phone.isEmpty else {
            alertLabel.text = "The field should not be empty"
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
                        print(exists)
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
        
        alertLabel.snp.makeConstraints { make in
            make.bottom.equalTo(phone.snp.top).offset(-10)
            make.centerX.equalToSuperview()
        }
        
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
