//
//  NewConversationViewController.swift
//  MessengerApp
//
//  Created by Eldiiar on 28/3/22.
//

import UIKit
import JGProgressHUD
import SnapKit

class NewConversationViewController: UIViewController {
    
    var completion: (([String: String]) -> ())?
    
    private var viewModel: NewConversationProtocol
    
    init(vm: NewConversationProtocol = NewConversationViewModel()) {
        viewModel = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
    }
    
    let spinner = JGProgressHUD(style: .dark)
    
    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Search for users"
        search.searchBarStyle = .minimal
        search.translatesAutoresizingMaskIntoConstraints = false
        return search
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.isHidden = false
        table.register(NewConversationTableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private lazy var label: UILabel = {
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
        viewModel.getUsers(tableView: tableView)
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRect(x: 0, y: 90, width: view.frame.width, height: view.frame.height)
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
        viewModel.results.removeAll()
        spinner.show(in: view)
        viewModel.filterUsers(with: text, spinner: spinner, label: label, tableView: tableView)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.isSearching = false
        label.isHidden = false
        searchBar.text = ""
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
}

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.isSearching {
            return viewModel.results.count
        } else {
            return viewModel.users.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewConversationTableViewCell
        if viewModel.isSearching {
            let name = viewModel.results[indexPath.row]["first_name"]! + " " + viewModel.results[indexPath.row]["last_name"]!
            let otherUserPhone = viewModel.results[indexPath.row]["phone"]
            cell.getData(name: name, otherUserPhone: otherUserPhone!)
        } else {
            let name = viewModel.users[indexPath.row]["first_name"]! + " " + viewModel.users[indexPath.row]["last_name"]!
            let otherUserPhone = viewModel.users[indexPath.row]["phone"]
            cell.getData(name: name, otherUserPhone: otherUserPhone!)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if viewModel.isSearching {
            let targetUserData = viewModel.results[indexPath.row]
            dismiss(animated: true) { [weak self] in
                self?.completion?(targetUserData)
            }
        } else {
            let targetUserData = viewModel.users[indexPath.row]
            dismiss(animated: true) { [weak self] in
                self?.completion?(targetUserData)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

