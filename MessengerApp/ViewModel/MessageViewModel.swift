//
//  MessageViewModel.swift
//  MessengerApp
//
//  Created by Eldiiar on 11/4/22.
//

import Foundation
import MessageKit

protocol MessageViewModelProtocol {
    var messages: [MessageModel] {get set}
    func createMessageId(otherUserPhone: String) -> String
    func listenForMessages(id: String, messagesCollectionView: MessagesCollectionView)
}

class MessageViewModel: MessageViewModelProtocol {
    var messages = [MessageModel]()
    
    func createMessageId(otherUserPhone: String) -> String {
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
    
    func listenForMessages(id: String, messagesCollectionView: MessagesCollectionView) {
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
                    messagesCollectionView.reloadData()
                }
            }
        }
    }
}
