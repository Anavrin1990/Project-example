//
//  ParamsSelectField.swift
//  TravelTogether
//
//  Created by Dmitry on 04.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation

import Foundation
import UIKit

protocol ParamsSelectFieldDelegate {
    func selectField(name: String, localResult: String)
}

class ParamsSelectField: ParamsAbstract, ParamsViewsProtocol {
    
    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    
    static var delegate: ParamsSelectFieldDelegate?
    
    var rawValue: String?
    var localValue: String?
    
    var rawResult: String?
    var localResult: String?
    
    static func initFromNib() -> ParamsSelectField {
        return Bundle.main.loadNibNamed("ParamsSelectField", owner: self, options: nil)?.first as! ParamsSelectField
    }
    
    func setView(placeholder: String?, parrent: UIViewController, name: String, rawValue: String?) {
        setAbstractView(placeholder: placeholder, parrent: parrent, name: name)
        checkLabel.text = placeholder
        checkImage.isHidden = true       
        self.rawValue = rawValue
        self.localValue = placeholder
    }
    
    func showHide() {
        abstractShowHide()
    }
    
    func hide() {
        abstractHide()
    }
    
    func getValue(complition: @escaping (String?, AnyHashable?, String?) -> ()) {
        complition(name, rawResult, localResult)
    }
    
    @IBAction func selectField(_ sender: Any) {
        
        rawResult = rawValue
        localResult = localValue
        
        ParamsSelectField.delegate?.selectField(name: name!, localResult: localResult!)        

        checkImage.isHidden = false
    }

}
