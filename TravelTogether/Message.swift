//
//  Message.swift
//  gameofchats
//
//  Created by Brian Voong on 7/7/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import Firebase

enum MessageStatus: String {
    
    case delivered
    case read
    
    var localValue: String {        
        switch self {
        case .delivered: return NSLocalizedString("Delivered", comment: "Delivered")
        case .read: return NSLocalizedString("Read", comment: "Read")
        }
    }
}

class Message: NSObject {
    
    var senderName: String?
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    var imageUrl: String?
    var type: String?
    var status: MessageStatus?
    var key: String?
    
    init(dictionary: [String: Any]) {
        self.senderName = dictionary["senderName"] as? String
        self.fromId = dictionary["fromId"] as? String
        self.text = dictionary["text"] as? String
        self.toId = dictionary["toId"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
        self.imageUrl = dictionary["imageUrl"] as? String
        self.type = dictionary["type"] as? String
        let status = dictionary["status"] as? String
        self.status = status == "delivered" ? .delivered : .read
    }
    
    func chatPartnerId() -> String? {
        return fromId == User.uid ? toId : fromId
    }
    
}
