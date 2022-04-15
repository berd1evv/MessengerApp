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
        formatter.dateFormat = "MM/dd/yy HH:mm:ss"
        formatter.locale = .current
        return formatter
    }()
    
    private let profileImage: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(systemName: "person")
        return img
    }()
    
    private let viewModel: MessageViewModelProtocol
    
    init(vm: MessageViewModelProtocol = MessageViewModel(), with phone: String, id: String?) {
        viewModel = vm
        self.otherUserPhone = phone
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
    }
    
    let otherUserPhone: String
    let conversationId: String?
    var isNewConversation = false
        
    var senderPhotoURL: URL?
    var otherUserURL: URL?
    
    
    
    var selfSender: SenderModel? {
        guard let phone = UserDefaults.standard.string(forKey: "phone") else {
            return nil
        }
        return SenderModel(photoURL: nil,
               senderId: phone,
               displayName: "John Snow")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        //navigationItem.titleView = profileImage
        navigationController?.navigationBar.backItem?.title = ""
        navigationController?.navigationBar.prefersLargeTitles = false
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messagesCollectionView.scrollToBottom(animated: true)
        if let conversationId = conversationId {
            viewModel.listenForMessages(id: conversationId, messagesCollectionView: messagesCollectionView)
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
                                   messageId: viewModel.createMessageId(otherUserPhone: otherUserPhone),
                              sentDate: Date(),
                              kind: .text(text))
        DatabaseManager.shared.createNewConversations(with: otherUserPhone, name: self.title ?? "User", firstMessage: message) {[weak self] success in
            if success {
                self?.viewModel.listenForMessages(id: self?.viewModel.createMessageId(otherUserPhone: self!.otherUserPhone) ?? "",
                                                  messagesCollectionView: self!.messagesCollectionView)
                self?.messagesCollectionView.reloadData()
            }
        }
    }
    
}

extension MessageViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, MessageCellDelegate {
    public func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self sender is nil")
    }
    
    public func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return  viewModel.messages[indexPath.section]
    }
    
    public func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return viewModel.messages.count
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        let indexPath = messagesCollectionView.indexPath(for: cell)
        print(viewModel.messages[indexPath!.section].sentDate)
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.addInteraction(interaction)
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

extension MessageViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint)
    -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { _ in
                let removeMessages = self.removeMessagesAction()
                let children = [removeMessages]

                return UIMenu(title: "", children: children)
            })
    }
    
    func removeMessagesAction() -> UIAction {
      let removeMessages = UIMenuElement.Attributes.destructive

      let deleteImage = UIImage(systemName: "trash")
      
      return UIAction(
        title: "Delete a message",
        image: deleteImage,
        identifier: nil,
        attributes: removeMessages) { _ in
          print("Message is deleted")
        }
    }

}
