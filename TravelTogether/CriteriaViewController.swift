//
//  CriteriaViewController.swift
//  TravelTogether
//
//  Created by Dmitry on 01.07.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit

class CriteriaViewController: UIViewController {

    @IBOutlet weak var dropStackView: DropStackView! {
        didSet {
            dropStackView.setDropStackView(self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        var componentsArray = [(String, [ParamsAbstract])]()
        
        let paramsTextField = ParamsTextField.initFromNib()
        paramsTextField.setView(placeholder: NSLocalizedString("Enter your name", comment: "Enter your name"), parrent: self, tag: 0, rawValue: nil)
        componentsArray.append(("name", [paramsTextField]))
        
        var smokingArray = [ParamsAbstract]()
        for i in iterateEnum(Profile.Smoking.self) {
            let paramsSelectField = ParamsSelectField.initFromNib()
            paramsSelectField.setView(placeholder: i.localValue, parrent: self, tag: 1, rawValue: i.rawValue)
            smokingArray.append(paramsSelectField)
        }
        componentsArray.append(("smoking", smokingArray))
        
        dropStackView.addComponents(componentsArray)

        
    }
    

}
