//
//  ChatNavigationView.swift
//  TravelTogether
//
//  Created by Dmitry on 16.07.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit

class ChatNavigationView: UIView {
    
    var lastSeen: String?
    var status: UserStatus? {
        didSet {
            setStatus()
        }
    }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusView: UIView! {
        didSet {
            statusView.layer.cornerRadius = statusView.frame.width / 2
        }
    }
    
    func setStatus() {
        guard let lastSeen = self.lastSeen else {return}
        
        let statusText = status?.localValue ?? ""
        var lastSeenText = ""
        
        if status == .offline {
            let currentDate = Date()
            let lastSeenDate = Date(timeIntervalSince1970: Double(lastSeen)!)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yy"
            let currentDay = dateFormatter.string(from: currentDate)
            let lastSeenDay = dateFormatter.string(from: lastSeenDate)
            
            if currentDay == lastSeenDay {
                dateFormatter.dateFormat = "HH:mm"
                lastSeenText = dateFormatter.string(from: lastSeenDate)
            } else {
                lastSeenText = dateFormatter.string(from: lastSeenDate)
            }
        }
        statusView.backgroundColor = status?.color
        statusLabel.text = statusText + lastSeenText
    }

}
