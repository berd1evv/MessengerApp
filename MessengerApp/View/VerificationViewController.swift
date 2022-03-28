//
//  VerificationViewController.swift
//  MessengerApp
//
//  Created by Eldiiar on 27/3/22.
//

import UIKit
import FirebaseAuth

class VerificationViewController: UIViewController {
    
    var destination = true
        
    let codeField: UITextField = {
        let text = UITextField()
        text.placeholder = "Enter verification code"
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
    
    let verifyButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 80, y: 320, width: 240, height: 60)
        button.setTitle("Verify", for: .normal)
        button.backgroundColor = .black
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(didTapVerifyButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(codeField)
        view.addSubview(verifyButton)
        
        codeField.delegate = self
    }
    
    
    @objc func didTapVerifyButton() {
        guard let code = codeField.text, !code.isEmpty else {
            if codeField.text!.isEmpty  {
                print("Field should not be empty")
            }
            return
        }
        if let text = codeField.text, !text.isEmpty {
            let code = text
            AuthManager.shared.verifyCode(code: code) { [weak self] success in
                guard success else { return }
                DispatchQueue.main.async {
                    if self?.destination == true {
                        let vc = TabBarViewController()
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }else {
                        let vc = RegisterViewController()
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                    
                }
            }
        }
        
    }
}

extension VerificationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapVerifyButton()
        return true
    }
}
