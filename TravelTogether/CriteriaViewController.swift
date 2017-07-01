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
        
        
        
//        var componentsArray = [(header: String, paramKey: String, fields: [ParamsAbstract]?, vc: UIViewController?)]()
//        
//        let paramsTextField = ParamsTextField.initFromNib()
//        paramsTextField.setView(placeholder: NSLocalizedString("Enter your name", comment: "Enter your name"), parrent: self, name: "name", rawValue: nil)
//        componentsArray.append((NSLocalizedString("Name", comment: "Name"), "name", [paramsTextField], nil))
//        
//        var smokingArray = [ParamsAbstract]()
//        for i in iterateEnum(Profile.Smoking.self) {
//            let paramsSelectField = ParamsSelectField.initFromNib()
//            paramsSelectField.setView(placeholder: i.localValue, parrent: self, name: "smoking", rawValue: i.rawValue)
//            smokingArray.append(paramsSelectField)
//        }
//        componentsArray.append(("Ssmoking", smokingArray, nil))
//        
//        let paramsDataPicker = ParamsDatePicker.initFromNib()
//        paramsDataPicker.setView(placeholder: NSLocalizedString("birthday", comment: "birthday"), parrent: self, name: "birthday", rawValue: nil)
//        componentsArray.append(("birthday", [paramsDataPicker], nil))
//        
//        let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchTableViewController") as! SearchTableViewController
//        searchVC.request = searchCountries
//        searchVC.name = "q8we"
//        componentsArray.append(("qwe", nil, searchVC))
//        
//        dropStackView.addComponents(componentsArray)

        
    }
    @IBAction func getValues(_ sender: Any) {
        print (dropStackView.getValue())
    }
    

}
