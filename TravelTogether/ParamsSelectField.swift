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

class ParamsSelectField: ParamsAbstract, ParamsViewsProtocol {
    
    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    
    static func initFromNib() -> ParamsSelectField {
        return Bundle.main.loadNibNamed("ParamsSelectField", owner: self, options: nil)?.first as! ParamsSelectField
    }
    
    func setView(placeholder: String?, parrent: UIViewController, tag: Int) {
        setAbstractView(placeholder: placeholder, parrent: parrent, tag: tag)
        checkLabel.text = placeholder
        checkImage.isHidden = true
    }
    
    func showHide() {
        abstractShowHide()
    }
    
    func hide() {
        abstractHide()
    }
    
    func getValue() {}
    
    @IBAction func selectField(_ sender: Any) {
        Person.profileDict[self.tag] = checkLabel.text
        
        ProfileViewController.paramsArray[ProfileViewController.selectedIndex!].stackView.subviews.forEach {
            if let field = $0 as? ParamsSelectField {
                field.checkImage.isHidden = true
                UIView.animate(withDuration: 0.3) {
                    field.hide()
                }                
            }
        }
        ProfileViewController.headersArray.enumerated().forEach {
            let text = Person.profileDict[$0.offset]
            if text != "" && text != nil {
                $0.element.paramValue.text = text
            }
        }
        checkImage.isHidden = false        
    }
    
    
    
}
