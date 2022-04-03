//
//  NewConversationViewController.swift
//  MessengerApp
//
//  Created by Eldiiar on 28/3/22.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    var completion: (([String: String]) -> ())?
    var users = [[String:String]]()
    var results = [[String:String]]()
    
    var hasFetched = false
    var isSearching = false
    
    let spinner = JGProgressHUD(style: .dark)
    
    let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Search for users"
        search.searchBarStyle = .minimal
        search.translatesAutoresizingMaskIntoConstraints = false
        return search
    }()
    
    let doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = false
        table.register(NewConversationTableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "No Results"
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
                
        view.addSubview(label)
        view.addSubview(doneButton)
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        setUpConstraints()
        getUsers()
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRect(x: 0, y: 90, width: view.frame.width, height: view.frame.height)
    }
    
    func getUsers() {
        DatabaseManager.shared.getAllUsersFirestore { [weak self] result in
            switch result {
            case .failure(let error):
                print("Failed to get users: \(error)")
            case .success(let usersCollection):
                self?.hasFetched = true
                self?.users = usersCollection as! [[String:String]]
                self?.filterOutCurrentUser()
                self?.tableView.reloadData()
            }
        }
    }
    
    func filterOutCurrentUser() {
        let phoneNumber = UserDefaults.standard.string(forKey: "phone") ?? ""
        let results: [[String:String]] = self.users.filter { filter in
            guard let number = filter["phone"], number != phoneNumber else {
                return false
            }
            return true
        }
        self.users = results
    }
    
    @objc func doneButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func setUpConstraints() {
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(40)
        }
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(90)
            make.height.equalTo(20)
        }
        
        doneButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.left.equalToSuperview().offset(20)
        }
    }
    
}

extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        results.removeAll()
        spinner.show(in: view)
        self.filterUsers(with: text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        self.label.isHidden = false
        searchBar.text = ""
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func filterUsers(with term: String) {
        guard hasFetched else {
            return
        }
        let phoneNumber = UserDefaults.standard.string(forKey: "phone") ?? ""
        
        self.spinner.dismiss(animated: true)
        
        let results: [[String:String]] = self.users.filter { filter in
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
        
        updateUI()
    }
    
    func updateUI() {
        if results.isEmpty {
            self.label.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.label.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return results.count
        } else {
            return users.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewConversationTableViewCell
        if isSearching {
            let name = results[indexPath.row]["first_name"]! + " " + results[indexPath.row]["last_name"]!
            let otherUserPhone = results[indexPath.row]["phone"]
            cell.getData(name: name, otherUserPhone: otherUserPhone!)
        } else {
            let name = users[indexPath.row]["first_name"]! + " " + users[indexPath.row]["last_name"]!
            let otherUserPhone = users[indexPath.row]["phone"]
            cell.getData(name: name, otherUserPhone: otherUserPhone!)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isSearching {
            let targetUserData = results[indexPath.row]
            dismiss(animated: true) { [weak self] in
                self?.completion?(targetUserData)
            }
        } else {
            let targetUserData = users[indexPath.row]
            dismiss(animated: true) { [weak self] in
                self?.completion?(targetUserData)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

