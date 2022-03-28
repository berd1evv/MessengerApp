//
//  RegisterViewController.swift
//  MessengerApp
//
//  Created by Eldiiar on 27/3/22.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    let login = LoginViewController()
            
    let imageView: UIImageView = {
        let image = UIImageView()
        image.frame = CGRect(x: 130, y: 100, width: 120, height: 120)
        image.image = UIImage(systemName: "person.circle")
        image.clipsToBounds = true
        image.layer.cornerRadius = 120 / 2
        image.layer.borderWidth = 1
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    let firstName: UITextField = {
        let text = UITextField()
        text.placeholder = "Enter first name"
        text.textAlignment = .center
        text.autocorrectionType = .no
        text.autocapitalizationType = .none
        text.returnKeyType = .continue
        text.frame = CGRect(x: 80, y: 240, width: 240, height: 60)
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
        text.frame = CGRect(x: 80, y: 320, width: 240, height: 60)
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
        text.frame = CGRect(x: 80, y: 400, width: 240, height: 60)
        text.clipsToBounds = true
        text.layer.cornerRadius = 5
        text.layer.borderWidth = 1
        text.layer.borderColor = UIColor.lightGray.cgColor
        return text
    }()
    
    let registrationButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 80, y: 560, width: 240, height: 60)
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .black
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
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
                
        DatabaseManager.shared.insertUser(with: User(firstName: firstName,
                                                     lastName: lastName,
                                                     email: email,
                                                     phone: "+996777063806"))
        
        navigationController?.pushViewController(TabBarViewController(), animated: true)
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
