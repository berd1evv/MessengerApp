//
//  DatabaseManager.swift
//  MessengerApp
//
//  Created by Eldiiar on 28/3/22.
//

import Foundation
import Firebase
import FirebaseFirestore

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    let db = Firestore.firestore()
    
    func userExistsFirestore(with phone: String, completion: @escaping (Bool) -> ()) {
        db.collection("users").document(phone).getDocument() { document, error in
            guard document?.data() != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func insertUserFirestore(with user: User, completion: @escaping (Bool) -> ()) {
        db.collection("users").document(user.phone).setData([
            "first_name" : user.firstName,
            "last_name" : user.lastName,
            "email" : user.email,
            "phone" : user.phone
        ]) { error in
            guard error == nil else {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    func getAllUsersFirestore(completion: @escaping (Result<[[String:Any]], Error>) -> ()) {
        db.collection("users").getDocuments() { querySnapshot, error in
            guard error == nil else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            var data: [[String: Any]] = []
            for doc in querySnapshot!.documents {
                data.append(doc.data())
            }
            completion(.success(data))
        }
    }
    
    func getCurrentUser(completion: @escaping(Result<[String:Any],Error>) -> ()) {
        db.collection("users").document(Auth.auth().currentUser?.phoneNumber ?? "0").addSnapshotListener { querySnapshot, error in
            guard error == nil else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            completion(.success(((querySnapshot?.data())!)))
        }
    }
    
    enum DatabaseErrors: Error {
        case failedToFetch
    }
    
    
}

// MARK: Conversations
extension DatabaseManager {
    //Creates new conversations
    func createNewConversations(with otherUserPhone: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> ()) {
        let phone = UserDefaults.standard.string(forKey: "phone") ?? ""
        let firstName = UserDefaults.standard.string(forKey: "firstName") ?? ""
        let lastName = UserDefaults.standard.string(forKey: "lastName") ?? ""
        let currentName = firstName + " " + lastName
        
        let conversationId = "conversation_\(firstMessage.messageId)"
        let messageDate = firstMessage.sentDate
        let dateString = MessageViewController.dateFormatter.string(from: messageDate)
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_), .photo(_), .video(_), .location(_), .emoji(_), .audio(_), .contact(_), .custom(_):
            break
        }
        
        db.collection("users").document(phone).collection("conversation").document(otherUserPhone).setData([
            "id": conversationId,
            "other_user_phone": otherUserPhone,
            "name" : name,
            "date_for_order": Date().timeIntervalSince1970,
            "latestMessage": [
                "date": dateString,
                "message": message,
                "is_read": false
            ]
        ])
        
        db.collection("users").document(otherUserPhone).collection("conversation").document(phone).setData([
            "id": conversationId,
            "other_user_phone": phone,
            "name": currentName,
            "date_for_order": Date().timeIntervalSince1970,
            "latestMessage": [
                "date": dateString,
                "message": message,
                "is_read": false
            ]
        ])
        
        finishCreatingConversation(name: name,
                                   conversationID: conversationId,
                                   firstMessage: firstMessage,
                                   completion: completion)
    }
    
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        let messageDate = firstMessage.sentDate
        let dateString = MessageViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_), .photo(_), .video(_), .location(_), .emoji(_), .audio(_), .contact(_), .custom(_):
            break
        }
        
        let currentUserPhone = Auth.auth().currentUser?.phoneNumber
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "content": message,
            "date": dateString,
            "date_for_order": Date().timeIntervalSince1970,
            "sender_phone": currentUserPhone!,
            "is_read": false,
            "name": name
        ]
        
        
        db.collection("conversations").document("messages").collection(conversationID).addDocument(data: collectionMessage) { error in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    //Fetches and returns all conversations
    func getAllConversation(for phone: String, completion: @escaping (Result<[Conversation], Error>) -> ()) {
        db.collection("users").document(phone).collection("conversation").order(by: "date_for_order", descending: true).addSnapshotListener { querySnapshot, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            if let snapshotDocuments = querySnapshot?.documents {
                var conversation: [Conversation] = []
                for doc in snapshotDocuments {
                    let latestMessage = doc.data()["latestMessage"] as! [String: Any]
                    conversation.append(Conversation(id: doc.data()["id"] as! String,
                                                     name: doc.data()["name"] as! String,
                                                     otherUserPhone: doc.data()["other_user_phone"] as! String,
                                                     latestMessage: LatestMessage(date: latestMessage["date"] as! String,
                                                                                  message: latestMessage["message"] as! String, isRead: latestMessage["is_read"] as! Bool)))
                }
                completion(.success(conversation))
            }
        }
    }
    //Gets all messages for a given conversation
    func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> ()) {
        db.collection("conversations").document("messages").collection(id).order(by: "date_for_order").addSnapshotListener { querySnapshot, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            var conversations: [Message] = []
            
            for doc in querySnapshot!.documents {
                let mess = doc.data()
                guard let name = mess["name"] as? String,
                      let isRead = mess["is_read"] as? Bool,
                      let messageId = mess["id"] as? String,
                      let content = mess["content"] as? String,
                      let senderPhone = mess["sender_phone"] as? String,
                      let dataString = mess["date"] as? String,
                      let date = MessageViewController.dateFormatter.date(from: dataString) else {
                          return
                      }
                
                let sender = Sender(photoURL: nil,
                                    senderId: senderPhone,
                                    displayName: name)
                
                conversations.append(Message(sender: sender,
                                                  messageId: messageId,
                                                  sentDate: date,
                                                  kind: .text(content)))
                
            }
            completion(.success(conversations))
            
        }
    }
}
