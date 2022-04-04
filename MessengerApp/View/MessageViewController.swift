//
//  MessagesViewController.swift
//  MessengerApp
//
//  Created by Eldiiar on 27/3/22.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class MessageViewController: MessagesViewController {
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .long
        formatter.dateFormat = "MM-dd-yy HH:mm"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        formatter.locale = .current
        return formatter
    }()
    
    let otherUserPhone: String
    let conversationId: String?
    var isNewConversation = false
        
    var senderPhotoURL: URL?
    var otherUserURL: URL?
    
    var messages = [MessageModel]()
    
    var selfSender: SenderModel? {
        guard let phone = UserDefaults.standard.string(forKey: "phone") else {
            return nil
        }
        return SenderModel(photoURL: nil,
               senderId: phone,
               displayName: "John Snow")
    }
    
    init(with phone: String, id: String?) {
        self.otherUserPhone = phone
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.backItem?.title = ""
        navigationController?.navigationBar.prefersLargeTitles = false
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messagesCollectionView.scrollToBottom(animated: true)
        if let conversationId = conversationId {
            listenForMessages(id: conversationId)
        }
    }
    
    func listenForMessages(id: String) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id) { [weak self] result in
            switch result {
            case .failure(let error):
                print("Failed to get messages:\(error)")
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                print("Successfully loaded messages")
                DispatchQueue.main.async {
                    self?.messages = messages
                    self?.messagesCollectionView.reloadData()
                }
            }
        }
    }

}

extension MessageViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let selfSender = selfSender else {
            return
        }
        messageInputBar.inputTextView.text = nil
        let message = MessageModel(sender: selfSender,
                              messageId: createMessageId(),
                              sentDate: Date(),
                              kind: .text(text))
        DatabaseManager.shared.createNewConversations(with: otherUserPhone, name: self.title ?? "User", firstMessage: message) {[weak self] success in
            if success {
                self?.listenForMessages(id: self?.createMessageId() ?? "")
                self?.messagesCollectionView.reloadData()
            }
        }
    }
    
    func createMessageId() -> String {
        guard let phone = UserDefaults.standard.string(forKey: "phone") else {
            return ""
        }
        
        let phoneId = phone.replacingOccurrences(of: "+", with: "") + otherUserPhone.replacingOccurrences(of: "+", with: "")
        var arr: [String] = []
        for i in phoneId {
            arr.append(String(i))
        }
        let intArray = arr.sorted().map { Int($0)!}

        var myString = ""
        _ = intArray.map{ myString = myString + "\($0)" }
        
        let id = myString
        return id
    }
}

extension MessageViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    public func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self sender is nil")
    }
    
    public func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return  messages[indexPath.section]
    }
    
    public func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            if let currentUserImageURL = senderPhotoURL {
                avatarView.sd_setImage(with: currentUserImageURL, completed: nil)
            } else {
                let phone = UserDefaults.standard.string(forKey: "phone") ?? ""
                let path = "images/" + phone + "_profile_picture.png"
                StorageManger.shared.downloadURL(for: path) { [weak self] result in
                    switch result {
                    case .success(let url):
                        self?.senderPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(let error):
                        print("Failed to get download: \(error)")
                    }
                }
            }
        } else {
            if let otherUserImageURL = otherUserURL {
                avatarView.sd_setImage(with: otherUserImageURL, completed: nil)
            } else {
                let path = "images/" + otherUserPhone + "_profile_picture.png"
                StorageManger.shared.downloadURL(for: path) { [weak self] result in
                    switch result {
                    case .success(let url):
                        self?.otherUserURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(let error):
                        print("Failed to get download: \(error)")
                    }
                }
            }
        }
    }
}
