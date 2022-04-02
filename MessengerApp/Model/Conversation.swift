//
//  File.swift
//  MessengerApp
//
//  Created by Eldiiar on 31/3/22.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserPhone: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let message: String
    let isRead: Bool
}
