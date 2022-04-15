//
//  ChatsViewController.swift
//  MessengerApp
//
//  Created by Eldiiar on 27/3/22.
//

import UIKit
import SnapKit

class ChatsViewController: UIViewController {
    
    let tableView = UITableView()
    
    private let viewModel: ChatsViewModelProtocol
    
    init(vm: ChatsViewModelProtocol = ChatsViewModel()) {
        viewModel = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
    }
    
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
        title = "Chats"
        
        view.addSubview(tableView)
        view.addSubview(plusButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatsTableViewCell.self, forCellReuseIdentifier: "cell")
        
        viewModel.startListeningConversations(tableView: tableView)
        viewModel.saveUserData()
        
        plusButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-30)
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(50)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.bounds
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
        for conv in viewModel.conversations {
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
        return viewModel.conversations.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChatsTableViewCell
        cell.getData(with: viewModel.conversations[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = MessageViewController(with: viewModel.conversations[indexPath.row].otherUserPhone,
                                       id: viewModel.conversations[indexPath.row].id)
        vc.title = viewModel.conversations[indexPath.row].name
        vc.isNewConversation = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
