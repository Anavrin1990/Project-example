//
//  ChatNavigationView.swift
//  TravelTogether
//
//  Created by Dmitry on 16.07.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit

class ChatNavigationView: UIView {
    
    var status: UserStatus? {
        didSet {
            statusView.backgroundColor = status?.color
            statusLabel.text = status?.localValue
        }
    }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusView: UIView! {
        didSet {
            statusView.layer.cornerRadius = statusView.frame.width / 2
        }
    }

}
