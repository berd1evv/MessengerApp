//
//  VerificationViewController.swift
//  MessengerApp
//
//  Created by Eldiiar on 27/3/22.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
import SnapKit

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
        [codeField1,
         codeField2,
         codeField3,
         codeField4,
         codeField5,
         codeField6].forEach { stack.addArrangedSubview($0) }
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        codeField1.becomeFirstResponder()
        
        view.addSubview(alertLabel)
        view.addSubview(stackView)
        
        codeField1.delegate = self
        codeField2.delegate = self
        codeField3.delegate = self
        codeField4.delegate = self
        codeField5.delegate = self
        codeField6.delegate = self
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        alertLabel.snp.makeConstraints { make in
            make.bottom.equalTo(stackView.snp.top).offset(-10)
            make.centerX.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().dividedBy(1.4)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
    }
}

extension VerificationViewController: UITextFieldDelegate {
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
                    guard success else {
                        self?.alertLabel.text = "Incorrect code!"
                        self?.codeField1.text = ""
                        self?.codeField2.text = ""
                        self?.codeField3.text = ""
                        self?.codeField4.text = ""
                        self?.codeField5.text = ""
                        self?.codeField6.text = ""
                        self?.codeField1.becomeFirstResponder()
                        self?.spinner.dismiss()
                        return
                    }
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
    }
}
