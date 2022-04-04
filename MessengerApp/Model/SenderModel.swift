//
//  Sender.swift
//  MessengerApp
//
//  Created by Eldiiar on 28/3/22.
//

import Foundation
import MessageKit

struct SenderModel: SenderType {
    var photoURL: String?
    var senderId: String
    var displayName: String
}
