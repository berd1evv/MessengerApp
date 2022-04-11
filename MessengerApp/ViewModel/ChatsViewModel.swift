//
//  ChatsViewModel.swift
//  MessengerApp
//
//  Created by Eldiiar on 11/4/22.
//

import Foundation
import Firebase
import UIKit

protocol ChatsViewModelProtocol {
    func saveUserData()
    func startListeningConversations(tableView: UITableView)
    var conversations: [ConversationModel] {get set}
}

class ChatsViewModel: ChatsViewModelProtocol {
    var conversations = [ConversationModel]()
    
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
    
    func startListeningConversations(tableView: UITableView) {
        DatabaseManager.shared.getAllConversation(for: (Auth.auth().currentUser?.phoneNumber)!) { [weak self] result in
            switch result {
            case .success(let conversations):
                self?.conversations = conversations
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
