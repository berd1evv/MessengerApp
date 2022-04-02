//
//  ChatsViewController.swift
//  MessengerApp
//
//  Created by Eldiiar on 27/3/22.
//

import UIKit
import Firebase
import SDWebImage

class ChatsViewController: UIViewController {
    
    let tableView = UITableView()
    var conversations = [Conversation]()
    
    let plusButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .blue
        button.tintColor = .white
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 50 / 2
        button.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        view.addSubview(plusButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatsTableViewCell.self, forCellReuseIdentifier: "cell")
        
        startListeningConversations()
        saveUserData()
        
        plusButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-30)
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(50)
        }
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.frame
    }
    
    func saveUserData() {
        DatabaseManager.shared.getCurrentUser { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let success):
                UserDefaults.standard.set(success["first_name"] as? String, forKey: "firstName")
                UserDefaults.standard.set(success["last_name"] as? String, forKey: "lastName")
                UserDefaults.standard.set(success["email"] as? String, forKey: "email")
            }
        }
    }
    
    func startListeningConversations() {
        DatabaseManager.shared.getAllConversation(for: (Auth.auth().currentUser?.phoneNumber)!) { result in
            switch result {
            case .success(let conversations):
                self.conversations = conversations
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    @objc func didTapPlusButton() {
        let vc = NewConversationViewController()
        vc.completion = {[weak self] result in
            self?.createNewUser(result: result)
        }
        navigationController?.present(vc, animated: true)
    }
    
    func createNewUser(result: [String:String]) {
        guard let firstName = result["first_name"], let lastName = result["last_name"], let phone = result["phone"] else {
            return
        }
        var conversationId = ""
        for conv in conversations {
            if conv.otherUserPhone == phone {
                conversationId = conv.id
            }
        }
        let name = firstName + " " + lastName
        if conversationId == "" {
            let vc = MessageViewController(with: phone, id: nil)
            vc.isNewConversation = true
            vc.title = name
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = MessageViewController(with: phone, id: conversationId)
            vc.isNewConversation = true
            vc.title = name
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
}

extension ChatsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChatsTableViewCell
        cell.getData(with: conversations[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = MessageViewController(with: conversations[indexPath.row].otherUserPhone, id: conversations[indexPath.row].id)
        vc.title = conversations[indexPath.row].name
        vc.isNewConversation = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
