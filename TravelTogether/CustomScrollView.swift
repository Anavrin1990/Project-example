//
//  CustomScrollView.swift
//  TravelTogether
//
//  Created by Dmitry on 04.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit

class CustomScrollView: UIScrollView {
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        return true
    }
    
}
