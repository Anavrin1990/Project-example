//
//  ParamsAbstract.swift
//  TravelTogether
//
//  Created by Dmitry on 04.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit

class ParamsAbstract: UIView, ParamsViewsProtocol {
    
    var parrent: UIViewController?
    var value: String?
    
    @IBOutlet weak var textField: UITextField! {
        didSet {setTextField()}
    }
    
    func setTextField() {
        textField?.borderStyle = .none
    }

    func setView(placeholder: String?, parrent: UIViewController, tag: Int) {
        self.tag = tag
        setAbstractView(placeholder: placeholder, parrent: parrent)
    }
    
    func setAbstractView(placeholder: String?, parrent: UIViewController) {
        self.isHidden = true
        textField?.placeholder = placeholder
        self.parrent = parrent
    }
    func showHide() {
        UIView.animate(withDuration: 0.3) {
            self.isHidden = !self.isHidden
        }
        
    }
    func hide() {
        self.isHidden = true
    }
    func getValue() {        
        getAbstractValue()
    }
    func getAbstractValue() {
        profileDict[self.tag] = textField.text        
    }
    
}
