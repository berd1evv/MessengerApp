//
//  MessageViewModel.swift
//  MessengerApp
//
//  Created by Eldiiar on 11/4/22.
//

import Foundation

protocol MessageViewModelProtocol {
    func createMessageId(otherUserPhone: String) -> String
}

class MessageViewModel: MessageViewModelProtocol {
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
}
