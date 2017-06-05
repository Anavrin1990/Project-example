//
//  ProfileCollectionViewCell.swift
//  TravelTogether
//
//  Created by Dmitry on 04.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var profileImage: UIImageView! {
        didSet {
            profileImage.layer.masksToBounds = true
            profileImage.layer.cornerRadius = profileImage.frame.width / 2
        }
    }
    
    
}
