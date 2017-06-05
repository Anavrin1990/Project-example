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

class ParamsSelectField: ParamsAbstract {
    
    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    
    static func initFromNib() -> ParamsSelectField {
        return Bundle.main.loadNibNamed("ParamsSelectField", owner: self, options: nil)?.first as! ParamsSelectField
    }
    
    override func setAbstractView(placeholder: String?, parrent: UIViewController) {
        super.setAbstractView(placeholder: placeholder, parrent: parrent)
        checkLabel.text = placeholder
        checkImage.isHidden = true
    }
    
    override func getAbstractValue() {
        
    }
    
    @IBAction func selectField(_ sender: Any) {
        profileDict[self.tag] = checkLabel.text
        
        ProfileViewController.paramsArray[ProfileViewController.selectedIndex!].stackView.subviews.forEach {
            if let field = $0 as? ParamsSelectField {
                field.checkImage.isHidden = true
                UIView.animate(withDuration: 0.3) {
                    field.hide()
                }                
            }
        }
        ProfileViewController.headersArray.enumerated().forEach {
            let text = profileDict[$0.offset]
            if text != "" && text != nil {
                $0.element.paramValue.text = text
            }
        }
        checkImage.isHidden = false        
    }
    
    
    
}
