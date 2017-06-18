//
//  Global.swift
//  TravelTogether
//
//  Created by Dmitry on 12.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

let spinner: UIActivityIndicatorView = {
    let spin = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    spin.translatesAutoresizingMaskIntoConstraints = false
    spin.color = UIColor.darkGray
    spin.hidesWhenStopped = true
    return spin
}()

func addSpinner(_ view: UIView) {
    
    view.addSubview(spinner)
    NSLayoutConstraint(item: spinner, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: spinner, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 0.85, constant: 0).isActive = true
}
