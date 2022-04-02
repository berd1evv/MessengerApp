//
//  VerificationViewController.swift
//  MessengerApp
//
//  Created by Eldiiar on 27/3/22.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class VerificationViewController: UIViewController {
    
    let spinner = JGProgressHUD(style: .dark)
    var destination = true
        
    let codeField: UITextField = {
        let text = UITextField()
        text.placeholder = "Enter verification code"
        text.textAlignment = .center
        text.autocorrectionType = .no
        text.autocapitalizationType = .none
        text.keyboardType = .numberPad
        text.returnKeyType = .done
        text.clipsToBounds = true
        text.layer.cornerRadius = 5
        text.layer.borderWidth = 1
        text.translatesAutoresizingMaskIntoConstraints = false
        text.layer.borderColor = UIColor.lightGray.cgColor
        return text
    }()
    
    let verifyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Verify", for: .normal)
        button.backgroundColor = .black
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapVerifyButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        codeField.becomeFirstResponder()
        
        view.addSubview(codeField)
        view.addSubview(verifyButton)
        
        codeField.delegate = self
        
        setUpConstraints()
    }
    
    
    @objc func didTapVerifyButton() {
        guard let code = codeField.text, !code.isEmpty, code.count == 6 else {
            if codeField.text!.isEmpty  {
                print("Field should not be empty")
            } else if codeField.text?.count != 6 {
                print("Code should be 6 digits")
            }
            return
        }
        spinner.show(in: view)
        if let text = codeField.text, !text.isEmpty {
            let code = text
            AuthManager.shared.verifyCode(code: code) { [weak self] success in
                guard success else { return }
                DispatchQueue.main.async {
                    self?.spinner.dismiss()
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
    
    func setUpConstraints() {
        codeField.snp.makeConstraints { make in
            make.top.equalTo(verifyButton.snp.top).offset(-70)
            make.width.equalToSuperview().dividedBy(1.5)
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
        }
        
        verifyButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().dividedBy(1.5)
            make.height.equalTo(60)
        }
    }
}

extension VerificationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapVerifyButton()
        return true
    }
}
