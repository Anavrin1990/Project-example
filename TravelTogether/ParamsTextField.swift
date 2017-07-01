//
//  ParamsTextField.swift
//  TravelTogether
//
//  Created by Dmitry on 04.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit

class ParamsTextField: ParamsAbstract, ParamsViewsProtocol {
    
    static func initFromNib() -> ParamsTextField {
        return Bundle.main.loadNibNamed("ParamsTextField", owner: self, options: nil)?.first as! ParamsTextField
    }
    
    func setView(placeholder: String?, parrent: UIViewController, tag: Int, rawValue: String?) {
        setAbstractView(placeholder: placeholder, parrent: parrent, tag: tag)
    }
    
    func showHide() {
        abstractShowHide()
    }
    
    func hide() {
        abstractHide()
    }
    
    func getValue() {
        Person.profileDict[self.tag] = (textField.text, textField.text)
    }
    
    

}
