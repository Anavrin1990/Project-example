//
//  ParamsTextField.swift
//  TravelTogether
//
//  Created by Dmitry on 04.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit

class ParamsTextField: ParamsAbstract {
    
    static func initFromNib() -> ParamsTextField {
        return Bundle.main.loadNibNamed("ParamsTextField", owner: self, options: nil)?.first as! ParamsTextField
    }

}
