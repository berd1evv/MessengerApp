//
//  Message.swift
//  MessengerApp
//
//  Created by Eldiiar on 28/3/22.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
