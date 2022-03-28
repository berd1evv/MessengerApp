//
//  ProfileViewController.swift
//  MessengerApp
//
//  Created by Eldiiar on 27/3/22.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    let leaveButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 80, y: 500, width: 240, height: 60)
        button.setTitle("Leave", for: .normal)
        button.tintColor = .red
        button.backgroundColor = .black
        button.addTarget(self, action: #selector(didTapLeaveButton), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white        
        
        view.addSubview(leaveButton)
    }
    
    @objc func didTapLeaveButton() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        navigationController?.pushViewController(LoginViewController(), animated: true)
        
    }

}
