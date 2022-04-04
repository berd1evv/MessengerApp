//
//  RegisterViewController.swift
//  MessengerApp
//
//  Created by Eldiiar on 27/3/22.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
import SnapKit

class RegisterViewController: UIViewController {
    
    let spinner = JGProgressHUD(style: .dark)
            
    let imageView: UIImageView = {
        let image = UIImageView()
        image.frame = CGRect(x: 130, y: 100, width: 120, height: 120)
        image.image = UIImage(systemName: "person.circle")
        image.clipsToBounds = true
        image.layer.cornerRadius = 120 / 2
        image.layer.borderWidth = 1
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let firstName: UITextField = {
        let text = UITextField()
        text.placeholder = "Enter first name"
        text.textAlignment = .center
        text.autocorrectionType = .no
        text.autocapitalizationType = .none
        text.returnKeyType = .continue
        text.translatesAutoresizingMaskIntoConstraints = false
        text.clipsToBounds = true
        text.layer.cornerRadius = 5
        text.layer.borderWidth = 1
        text.layer.borderColor = UIColor.lightGray.cgColor
        return text
    }()
    
    let lastName: UITextField = {
        let text = UITextField()
        text.placeholder = "Enter last name"
        text.textAlignment = .center
        text.autocorrectionType = .no
        text.returnKeyType = .continue
        text.translatesAutoresizingMaskIntoConstraints = false
        text.clipsToBounds = true
        text.layer.cornerRadius = 5
        text.layer.borderWidth = 1
        text.layer.borderColor = UIColor.lightGray.cgColor
        return text
    }()
    
    let email: UITextField = {
        let text = UITextField()
        text.placeholder = "Enter email"
        text.textAlignment = .center
        text.autocorrectionType = .no
        text.autocapitalizationType = .none
        text.returnKeyType = .continue
        text.translatesAutoresizingMaskIntoConstraints = false
        text.clipsToBounds = true
        text.layer.cornerRadius = 5
        text.layer.borderWidth = 1
        text.layer.borderColor = UIColor.lightGray.cgColor
        return text
    }()
    
    let registrationButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .black
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(imageView)
        view.addSubview(firstName)
        view.addSubview(lastName)
        view.addSubview(email)
        view.addSubview(registrationButton)
        
        firstName.delegate = self
        lastName.delegate = self
        email.delegate = self
                
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePicture))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(gesture)
        
        setUpConstraints()
    }
    
    
    @objc func didTapChangeProfilePicture() {
        presentPhotoActionSheet()
    }
    
    @objc func didTapRegisterButton() {
        guard let firstName = firstName.text,
              let lastName = lastName.text,
              let email = email.text,
              !firstName.isEmpty,
              !lastName.isEmpty,
              !email.isEmpty else {
                  if firstName.text!.isEmpty || lastName.text!.isEmpty || email.text!.isEmpty {
                      print("Fields should not be empty")
                  }
                  return
        }
        spinner.show(in: view)
        
        let number = UserDefaults.standard.string(forKey: "phone") ?? ""
        
        let user = UserModel(firstName: firstName,
                        lastName: lastName,
                        email: email,
                        phone: number)

        
        DatabaseManager.shared.insertUserFirestore(with: user) { [weak self] success in
            if success {
                guard let image = self?.imageView.image, let data = image.pngData() else {
                    return
                }
                let fileName = user.profilePictureFileName
                StorageManger.shared.uploadProfilePicture(with: data, fileName: fileName) { result in
                    switch result {
                    case .success(let downloadURL):
                        UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                    case .failure(_):
                        print("Storage manager error")
                    }
                }
            }
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.spinner.dismiss()
            self?.navigationController?.pushViewController(TabBarViewController(), animated: true)
        }
        
    }
    
    func setUpConstraints() {
        imageView.snp.makeConstraints { make in
            make.bottom.equalTo(firstName.snp.bottom).offset(-70)
            make.width.height.equalTo(120)
            make.centerX.equalToSuperview()
        }
        
        firstName.snp.makeConstraints { make in
            make.bottom.equalTo(lastName.snp.top).offset(-20)
            make.height.equalTo(60)
            make.width.equalToSuperview().dividedBy(1.5)
            make.centerX.equalToSuperview()
        }
        
        lastName.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalToSuperview().dividedBy(1.5)
        }
        
        email.snp.makeConstraints { make in
            make.top.equalTo(lastName.snp.bottom).offset(20)
            make.height.equalTo(60)
            make.width.equalToSuperview().dividedBy(1.5)
            make.centerX.equalToSuperview()
        }
        
        registrationButton.snp.makeConstraints { make in
            make.top.equalTo(email.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalToSuperview().dividedBy(1.5)
        }
    }

}

extension RegisterViewController: UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstName {
            lastName.becomeFirstResponder()
        } else if textField == lastName {
            email.becomeFirstResponder()
        } else if textField == email {
            didTapRegisterButton()
        }
        return true
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile picture", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take a photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose a photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
