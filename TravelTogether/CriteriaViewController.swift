//
//  CriteriaViewController.swift
//  TravelTogether
//
//  Created by Dmitry on 01.07.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit

class CriteriaViewController: UIViewController {
    
    var componentsArray = [(header: String, paramKey: String, fields: [ParamsAbstract]?, instantiateVC: UIViewController?)]()

    @IBOutlet weak var dropStackView: DropStackView! {
        didSet {
            dropStackView.setDropStackView(self)
            addDropList()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func getValues(_ sender: Any) {
        print (dropStackView.getValue())
    }
    
    func addDropList() {
        
        var sexArray = [ParamsAbstract]()
        for i in iterateEnum(Profile.Sex.self) {
            let paramsSelectField = ParamsSelectField.initFromNib()
            paramsSelectField.setView(placeholder: i.localValue, parrent: self, name: "sex", rawValue: i.rawValue)
            sexArray.append(paramsSelectField)
        }
        componentsArray.append(("sex", NSLocalizedString("Sex", comment: "Sex"), sexArray, nil))
        
        let ageField = ParamsTextField.initFromNib()
        ageField.setView(placeholder: NSLocalizedString("Age of companion", comment: "Age of companion"), parrent: self, name: "age", rawValue: nil)
        componentsArray.append(("age", NSLocalizedString("Age", comment: "Age"), [ageField], nil))
        
        let countryField = self.storyboard?.instantiateViewController(withIdentifier: "SearchTableViewController") as! SearchTableViewController
        countryField.request = searchCountries
        countryField.name = "country"
        componentsArray.append(("country", NSLocalizedString("Country", comment: "Country"), nil, countryField))
        
        let cityField = self.storyboard?.instantiateViewController(withIdentifier: "SearchTableViewController") as! SearchTableViewController
        cityField.request = searchCities
        cityField.name = "city"
        componentsArray.append(("city", NSLocalizedString("City", comment: "City"), nil, cityField))
        
        let destinationField = self.storyboard?.instantiateViewController(withIdentifier: "SearchTableViewController") as! SearchTableViewController
        destinationField.request = searchCountries
        destinationField.name = "destination"
        componentsArray.append(("destination", NSLocalizedString("Destination", comment: "Destination"), nil, destinationField))
        
        let monthField = ParamsDatePicker.initFromNib()
        monthField.onlyMonth = true
        monthField.setTextField()
        monthField.setView(placeholder: NSLocalizedString("Month", comment: "Month"), parrent: self, name: "month", rawValue: nil)        
        componentsArray.append(("month", NSLocalizedString("Month", comment: "Month"), [monthField], nil))
        
        var alcoholArray = [ParamsAbstract]()
        for i in iterateEnum(Profile.Alcohol.self) {
            let paramsSelectField = ParamsSelectField.initFromNib()
            paramsSelectField.setView(placeholder: i.localValue, parrent: self, name: "alcohol", rawValue: i.rawValue)
            alcoholArray.append(paramsSelectField)
        }
        componentsArray.append(("alcohol", NSLocalizedString("Alcohol", comment: "Alcohol"), alcoholArray, nil))
        
        var smokingArray = [ParamsAbstract]()
        for i in iterateEnum(Profile.Smoking.self) {
            let paramsSelectField = ParamsSelectField.initFromNib()
            paramsSelectField.setView(placeholder: i.localValue, parrent: self, name: "smoking", rawValue: i.rawValue)
            smokingArray.append(paramsSelectField)
        }
        componentsArray.append(("smoking", NSLocalizedString("Smoking", comment: "Smoking"), smokingArray, nil))
        
        var familyArray = [ParamsAbstract]()
        for i in iterateEnum(Profile.Family.self) {
            let paramsSelectField = ParamsSelectField.initFromNib()
            paramsSelectField.setView(placeholder: i.localValue, parrent: self, name: "familyStatus", rawValue: i.rawValue)
            familyArray.append(paramsSelectField)
        }
        componentsArray.append(("familyStatus", NSLocalizedString("Family status", comment: "Family status"), familyArray, nil))
        
        var childsArray = [ParamsAbstract]()
        for i in iterateEnum(Profile.Childs.self) {
            let paramsSelectField = ParamsSelectField.initFromNib()
            paramsSelectField.setView(placeholder: i.localValue, parrent: self, name: "childs", rawValue: i.rawValue)
            childsArray.append(paramsSelectField)
        }
        componentsArray.append(("childs", NSLocalizedString("Have children", comment: "Have children"), childsArray, nil))
        
        var orientationArray = [ParamsAbstract]()
        for i in iterateEnum(Profile.Orientation.self) {
            let paramsSelectField = ParamsSelectField.initFromNib()
            paramsSelectField.setView(placeholder: i.localValue, parrent: self, name: NSLocalizedString("orientation", comment: "Sexual orientation"), rawValue: i.rawValue)
            orientationArray.append(paramsSelectField)
        }
        componentsArray.append(("orientation", NSLocalizedString("Sexual orientation", comment: "Sexual orientation"), orientationArray, nil))
        
        dropStackView.addComponents(componentsArray)
    }
    

}
