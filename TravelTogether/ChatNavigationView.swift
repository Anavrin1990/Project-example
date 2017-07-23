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
    
    func setStatus() {
        guard let lastSeen = self.lastSeen else {return}
        
        let statusText = status?.localValue ?? ""
        var lastSeenText = ""
        
        if status == .offline {
            lastSeenText = isTodayDate(Double(lastSeen)! as NSNumber)
        }        
        statusLabel.text = statusText + lastSeenText
    }

}
