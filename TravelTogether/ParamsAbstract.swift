//
//  ParamsAbstract.swift
//  TravelTogether
//
//  Created by Dmitry on 04.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit

protocol ParamsViewsProtocol {    
    func setView(placeholder: String?, parrent: UIViewController, tag: Int)
    func showHide()
    func hide()
    func getValue()
}

class ParamsAbstract: UIView {
    
    var parrent: UIViewController?
    var value: String?
    
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
    
    func setAbstractView(placeholder: String?, parrent: UIViewController, tag: Int) {
        self.tag = tag
        self.isHidden = true
        textField?.placeholder = placeholder
        self.parrent = parrent
    }
    
    
    
}
