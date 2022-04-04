//
//  ChatsTableViewCell.swift
//  MessengerApp
//
//  Created by Eldiiar on 31/3/22.
//

import UIKit
import SnapKit

class ChatsTableViewCell: UITableViewCell {
    
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
    
    let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let userMessageSentDate: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(userNameLabel)
        addSubview(userMessageLabel)
        addSubview(userMessageSentDate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        setUpConstraints()
    }
    
    func getData(with model: ConversationModel) {
        userNameLabel.text = model.name
        userMessageLabel.text = model.latestMessage.message
        userMessageSentDate.text = model.latestMessage.date
        
        let path = "images/\(model.otherUserPhone)_profile_picture.png"
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
            make.top.equalTo(5)
        }
        
        userMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(3)
            make.left.equalTo(profileImageView.snp.right).offset(10)
            make.width.equalToSuperview().offset(-90)
            make.height.equalTo(20)
        }
        
        userMessageSentDate.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-5)
            make.right.equalToSuperview().offset(-5)
        }
    }
    
    
}
