//
//  ParamsAbstract.swift
//  TravelTogether
//
//  Created by Dmitry on 04.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit

protocol ParamsViewsProtocol {    
    func setView(placeholder: String?, parrent: UIViewController, name: String, rawValue: String?)
    func showHide()
    func hide()
    func getValue(complition: @escaping (_ name: String?, _ value: AnyHashable?, _ localValue: String?) -> ())
}

class ParamsAbstract: UIView {
    
    var parrent: UIViewController?
    var value: String?
    
    var name: String?
    
    @IBOutlet weak var textField: UITextField! {
        didSet {setTextField()}
    }
    
    func setTextField() {
        textField?.borderStyle = .none
    }

    func abstractShowHide() {
        UIView.animate(withDuration: 0.3) {
            self.isHidden = !self.isHidden
        }
    }
    
    func abstractHide() {
        self.isHidden = true
    }
    
    func setAbstractView(placeholder: String?, parrent: UIViewController, name: String) {
        self.name = name
        self.isHidden = true
        textField?.placeholder = placeholder
        self.parrent = parrent
    }
    
    
    
}
