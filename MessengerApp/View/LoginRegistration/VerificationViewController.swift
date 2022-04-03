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
        
    let alertLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let codeField1: UITextField = {
        let text = UITextField()
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
    
    let codeField2: UITextField = {
        let text = UITextField()
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
    
    let codeField3: UITextField = {
        let text = UITextField()
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
    
    let codeField4: UITextField = {
        let text = UITextField()
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
    
    let codeField5: UITextField = {
        let text = UITextField()
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
    
    let codeField6: UITextField = {
        let text = UITextField()
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
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10.0
        stack.alignment = .fill
        stack.distribution = .fillEqually
        [self.codeField1,
         self.codeField2,
         self.codeField3,
         self.codeField4,
         self.codeField5,
         self.codeField6].forEach { stack.addArrangedSubview($0) }
        return stack
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
        
        codeField1.becomeFirstResponder()
        
        view.addSubview(alertLabel)
        view.addSubview(stackView)
        view.addSubview(verifyButton)
        
        codeField1.delegate = self
        codeField2.delegate = self
        codeField3.delegate = self
        codeField4.delegate = self
        codeField5.delegate = self
        
        setUpConstraints()
    }
    
    
    @objc func didTapVerifyButton() {
        guard let code = codeField6.text, !code.isEmpty else {
            if codeField1.text!.isEmpty  {
                alertLabel.text = "Field should not be empty"
            }
            return
        }
        spinner.show(in: view)
        if let text = codeField6.text, !text.isEmpty {
            let code = codeField1.text! + codeField2.text! + codeField3.text! + codeField4.text! + codeField5.text! + codeField6.text!
            
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
        alertLabel.snp.makeConstraints { make in
            make.bottom.equalTo(stackView.snp.top).offset(-10)
            make.centerX.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(verifyButton.snp.top).offset(-90)
            make.width.equalToSuperview().dividedBy(1.4)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
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
        if codeField6.text?.count == 1 {
            didTapVerifyButton()
        }
        return true
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if codeField1.text?.count == 1 {
            codeField2.becomeFirstResponder()
        }
        
        if codeField2.text?.count == 1 {
            codeField3.becomeFirstResponder()
        }
        if codeField3.text?.count == 1 {
            codeField4.becomeFirstResponder()
        }
        if codeField4.text?.count == 1 {
            codeField5.becomeFirstResponder()
        }
        if codeField5.text?.count == 1 {
            codeField6.becomeFirstResponder()
        }
        if codeField6.text?.count == 1 {
            didTapVerifyButton()
        }
    }
}
