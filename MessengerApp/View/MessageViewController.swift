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
        formatter.locale = .current
        return formatter
    }()
    
    let otherUserPhone: String
    let conversationId: String?
    var isNewConversation = false
    
    var messages = [Message]()
    
    var selfSender: Sender? {
        guard let phone = UserDefaults.standard.string(forKey: "phone") else {
            return nil
        }
        return Sender(photoURL: "gs://messenger-app-9bad4.appspot.com/images/" + phone + "_profile_picture.png",
               senderId: phone,
               displayName: "John Snow")
    }
    
    init(with phone: String, id: String?) {
        self.otherUserPhone = phone
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)
        if let conversationId = conversationId {
            listenForMessages(id: conversationId)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.backItem?.title = ""
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
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
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                }
            }
        }
    }

}

extension MessageViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let selfSender = self.selfSender else {
            return
        }

        if isNewConversation {
            let message = Message(sender: selfSender,
                                  messageId: createMessageId(),
                                  sentDate: Date(),
                                  kind: .text(text))
            DatabaseManager.shared.createNewConversations(with: otherUserPhone, name: self.title ?? "User", firstMessage: message) {[weak self] success in
                if success {
                    print("message sent ")
                    self?.messagesCollectionView.reloadData()
                }
            }
        } else {
            print("message was not sent")
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
    
    
}
