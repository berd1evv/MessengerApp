//
//  NewConversationTableViewCell.swift
//  MessengerApp
//
//  Created by Eldiiar on 1/4/22.
//

import UIKit

class NewConversationTableViewCell: UITableViewCell {

    let profileImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        image.layer.cornerRadius = 25
        return image
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(userNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        setUpConstraints()
    }
    
    func getData(name: String, otherUserPhone: String) {
        userNameLabel.text = name
        
        let path = "images/\(otherUserPhone)_profile_picture.png"
        StorageManger.shared.downloadURL(for: path) { [weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.profileImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("Failed to fetch image \(error)")
            }
        }
    }
    
    func setUpConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(5)
            make.centerY.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.left.equalTo(profileImageView.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }

    }

}
