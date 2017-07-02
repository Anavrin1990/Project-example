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
    
    func setView(placeholder: String?, parrent: UIViewController, name: String, rawValue: String?) {
        setAbstractView(placeholder: placeholder, parrent: parrent, name: name)
    }
    
    func showHide() {
        abstractShowHide()
    }
    
    func hide() {
        abstractHide()
    }
    
    func getValue(complition: @escaping (String?, AnyHashable?, String?) -> ()) {
        //Person.profileDict[self.tag] = (textField.text, textField.text)
        complition(name, textField.text, textField.text)
    }
    

}
