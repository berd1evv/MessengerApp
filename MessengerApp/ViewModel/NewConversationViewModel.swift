//
//  NewConversationViewModel.swift
//  MessengerApp
//
//  Created by Eldiiar on 11/4/22.
//

import UIKit
import JGProgressHUD

protocol NewConversationProtocol {
    var users: [[String:String]] {get set}
    var results: [[String:String]] {get set}
    var hasFetched: Bool {get set}
    var isSearching: Bool {get set}
    func getUsers(tableView: UITableView)
    func filterUsers(with term: String, spinner: JGProgressHUD, label: UILabel, tableView: UITableView)
}

class NewConversationViewModel: NewConversationProtocol {
    var users = [[String:String]]()
    var results = [[String:String]]()
    var hasFetched = false
    var isSearching = false
    
    func getUsers(tableView: UITableView) {
        DatabaseManager.shared.getAllUsersFirestore { [weak self] result in
            switch result {
            case .failure(let error):
                print("Failed to get users: \(error)")
            case .success(let usersCollection):
                self?.hasFetched = true
                self?.users = usersCollection as! [[String:String]]
                self?.filterOutCurrentUser()
                tableView.reloadData()
            }
        }
    }
    
    func filterOutCurrentUser() {
        let phoneNumber = UserDefaults.standard.string(forKey: "phone") ?? ""
        let results: [[String:String]] = users.filter { filter in
            guard let number = filter["phone"], number != phoneNumber else {
                return false
            }
            return true
        }
        users = results
    }
    
    func filterUsers(with term: String, spinner: JGProgressHUD, label: UILabel, tableView: UITableView) {
        guard hasFetched else {
            return
        }
        let phoneNumber = UserDefaults.standard.string(forKey: "phone") ?? ""
        
        spinner.dismiss(animated: true)
        
        let results: [[String:String]] = users.filter { filter in
            guard let number = filter["phone"], number != phoneNumber else {
                return false
            }
            
            guard let firstName = filter["first_name"]?.lowercased() else {
                return false
            }
            
            guard let lastName = filter["last_name"]?.lowercased() else {
                return false
            }
            
            return firstName.hasPrefix(term.lowercased()) || lastName.hasPrefix(term.lowercased())
        }
        self.results = results
        isSearching = true
        
        updateUI(label: label, tableView: tableView)
    }
    
    func updateUI(label: UILabel, tableView: UITableView) {
        if results.isEmpty {
            label.isHidden = false
            tableView.isHidden = true
        } else {
            label.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}
