//
//  UserCell.swift
//  gameofchats
//
//  Created by Brian Voong on 7/8/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView! 
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var onlineView: UIView! {
        didSet {
            onlineView.layer.cornerRadius = onlineView.frame.width / 2
        }
    }
    @IBOutlet weak var imageContainerView: UIView! {
        didSet {
            imageContainerView.layer.cornerRadius = imageContainerView.frame.width / 2
            imageContainerView.layer.masksToBounds = true
        }
    }
    var message: Message? {
        didSet {
            setupCell()            
        }
    }
    fileprivate func setupCell() {
        // Setup time
        messageLabel?.text = message?.text
        
        if let timestamp = message?.timestamp {
            timeLabel.text = isTodayDate(timestamp)
        }
        
        // Setup name and text
        if let id = message?.chatPartnerId() {
            let userRef = Request.ref.child("Users").child(id)
            Request.singleRequest(reference: userRef, type: .value, completion: { (snapshot, error) in
                
                if let dictionary = snapshot?.value as? [String: AnyObject] {
                    let user = User(dictionary: dictionary)
                    self.nameLabel?.text = user.person?.name
                    self.onlineView.isHidden = user.status == .offline
                    self.profileImageView.getImage(url: user.icon)
                }
                
                // Setup status
                Request.observeRequest(reference: userRef, type: .childChanged, completion: { (snapshot, error) in
                    guard let status = snapshot?.value as? String, snapshot?.key == "status" else {return}
                    let stringArray = status.components(separatedBy: "_")
                    self.onlineView.isHidden = stringArray[0] == "offline"                    
                })
            })
        }
    }
    
}
