//
//  ProfileViewController.swift
//  MessengerApp
//
//  Created by Eldiiar on 27/3/22.
//

import UIKit
import Firebase
import SDWebImage

class ProfileViewController: UIViewController {
    
    let tableView = UITableView()
    let data = ["Account", "Log out"]
    var currentUser: [String:Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.frame
    }
    
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        if cell.textLabel?.text == "Log out" {
            cell.textLabel?.textColor = .red
            cell.imageView?.image = UIImage(systemName: "rectangle.portrait.and.arrow.right.fill")
        } else {
            cell.imageView?.image = UIImage(systemName: "person.crop.square.fill")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if data[indexPath.row] == "Log out" {
            let actionSheet = UIAlertController(title: "Are you sure you want to log out?",
                                                message: "",
                                                preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                let firebaseAuth = Auth.auth()
                do {
                    try firebaseAuth.signOut()
                    strongSelf.navigationController?.pushViewController(LoginViewController(), animated: true)
                } catch let signOutError as NSError {
                    print("Error signing out: %@", signOutError)
                }
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: nil))
            
            self.present(actionSheet, animated: true)
            
        } else if data[indexPath.row] == "Account" {
            let firstName = UserDefaults.standard.string(forKey: "firstName")
            let lastName = UserDefaults.standard.string(forKey: "lastName")
            let email = UserDefaults.standard.string(forKey: "email")
            let phone = UserDefaults.standard.string(forKey: "phone") ?? ""
            
            let fileName = phone + "_profile_picture.png"
            let path = "images/" + fileName
            
            let vc = RegisterViewController()
            
            StorageManger.shared.downloadURL(for: path) { result in
                switch result {
                case .success(let url):
                    vc.imageView.sd_setImage(with: url, completed: nil)
                case .failure(let error):
                    print("Failed to get download: \(error)")
                }
            }
            
            vc.firstName.text = firstName
            vc.lastName.text = lastName
            vc.email.text = email
            vc.registrationButton.setTitle("Save", for: .normal)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 100))
        
        let phone = UserDefaults.standard.string(forKey: "phone") ?? ""
        let fileName = phone + "_profile_picture.png"
        let path = "images/" + fileName
        
        let image = UIImageView()
        image.frame = CGRect(x: 20, y: 0, width: 90, height: 90)
        image.image = UIImage(systemName: "person.circle")
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.layer.cornerRadius = image.frame.width / 2
        image.layer.borderWidth = 1
        image.contentMode = .scaleAspectFit
        
        StorageManger.shared.downloadURL(for: path) { result in
            switch result {
            case .success(let url):
                image.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print("Failed to get download: \(error)")
            }
        }
        
        let label = UILabel()
        let firstName = UserDefaults.standard.string(forKey: "firstName")
        let lastName = UserDefaults.standard.string(forKey: "lastName")
        label.text = "\(firstName!) \(lastName!)"
        label.font = .systemFont(ofSize: 20)
        label.frame = CGRect(x: 120, y: 10, width: 180, height: 40)
        
        headerView.addSubview(image)
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
}
