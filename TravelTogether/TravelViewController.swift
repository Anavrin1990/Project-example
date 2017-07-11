//
//  TravelViewController.swift
//  TravelTogether
//
//  Created by Dmitry on 24.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit

class TravelViewController: UIViewController, SearchTableViewDelegate {
    
    var destination: String?
    var monthNumber: String?
    var monthString: String?
    
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var monthTextField: UITextField! {
        didSet {
            setTextField()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        SearchTableViewController.delegate = self
        Request.getUserInfo{}
    }
    @IBAction func cancelClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectButton(_ sender: Any) {
        let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchTableViewController") as! SearchTableViewController
        emptySearchName = ("", "")
        searchVC.request = searchCountries(_:)
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    @IBAction func onDoneClick(_ sender: Any) {
        self.view.endEditing(true)
        if let destination = destination, let month = monthNumber, monthTextField.text != "", let uid = User.uid {
            
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyMMddHHmmss"
            
            let stringDate = dateFormatter.string(from: date)
            let ageRange = User.person!.birthday!.getAgeRange()!
            let userCountry = User.person!.country!
            let userCity = User.person!.city!
            var travelId = ""
            var travelKey = ""
            
            var travelValues = [String : Any]()
            travelValues["destination"] = destination
            travelValues["month"] = month
            travelValues["createdate"] = Int(stringDate)
            travelValues["icon"] = User.icon
            travelValues["name"] = User.person?.name
            travelValues["birthday"] = User.person?.birthday
            travelValues["uid"] = User.uid
            travelValues["sex"] = User.person?.sex            
            travelValues["country"] = User.person?.country
            travelValues["city"] = User.person?.city
            
            if User.firstTravel == "" {
                travelId = User.uid! + "_first"
                travelKey = "firstTravel"
            } else if User.secondTravel == "" {
                travelId = User.uid! + "_second"
                travelKey = "secondTravel"
            } else if User.thirdTravel == "" {
                travelId = User.uid! + "_third"
                travelKey = "thirdTravel"
            } else {
                MessageBox.showMessage(parent: self, title: NSLocalizedString("Maximum is 3 travels", comment: "Maximum is 3 travels"), message: "")
                return
            }
            
            let userSex = User.person!.sex!.capitalized
            
            Request.updateChildValue(reference: Request.ref.child("Users").child(uid), value: [travelKey : travelId], complition: {
                
                
                // Update Criteria
                Request.updateChildValue(reference: Request.ref.child("Criteria").child("destination").child(travelId), value: ["destination" : destination], complition: {})
                Request.updateChildValue(reference: Request.ref.child("Criteria").child("month").child(travelId), value: ["month" : month], complition: {})
                
                
                // Update UsersTravels
                Request.updateChildValue(reference: Request.ref.child("UsersTravels").child(travelId), value: travelValues, complition: {})
                
                // Update Destinations
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Destinations").child("AllCountries").child("AllCities").child(destination).child(ageRange).child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Destinations").child("AllCountries").child("AllCities").child(destination).child(ageRange).child(userSex).child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Destinations").child("AllCountries").child("AllCities").child(destination).child("AllAges").child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Destinations").child("AllCountries").child("AllCities").child(destination).child("AllAges").child(userSex).child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Destinations").child(userCountry).child("AllCities").child(destination).child(ageRange).child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Destinations").child(userCountry).child("AllCities").child(destination).child(ageRange).child(userSex).child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Destinations").child(userCountry).child(userCity).child(destination).child(ageRange).child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Destinations").child(userCountry).child(userCity).child(destination).child(ageRange).child(userSex).child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Destinations").child(userCountry).child("AllCities").child(destination).child("AllAges").child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Destinations").child(userCountry).child("AllCities").child(destination).child("AllAges").child(userSex).child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Destinations").child(userCountry).child(userCity).child(destination).child("AllAges").child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Destinations").child(userCountry).child(userCity).child(destination).child("AllAges").child(userSex).child(travelId), value: travelValues, complition: {})
                
                
                // Update Match
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Match").child("AllCountries").child("AllCities").child(destination).child(month).child(ageRange).child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Match").child("AllCountries").child("AllCities").child(destination).child(month).child(ageRange).child(userSex).child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Match").child("AllCountries").child("AllCities").child(destination).child(month).child("AllAges").child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Match").child("AllCountries").child("AllCities").child(destination).child(month).child("AllAges").child(userSex).child(travelId), value: travelValues, complition: {})
                
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Match").child(userCountry).child("AllCities").child(destination).child(month).child(ageRange).child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Match").child(userCountry).child("AllCities").child(destination).child(month).child(ageRange).child(userSex).child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Match").child(userCountry).child(userCity).child(destination).child(month).child(ageRange).child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Match").child(userCountry).child(userCity).child(destination).child(month).child(ageRange).child(userSex).child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Match").child(userCountry).child("AllCities").child(destination).child(month).child("AllAges").child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Match").child(userCountry).child("AllCities").child(destination).child(month).child("AllAges").child(userSex).child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Match").child(userCountry).child(userCity).child(destination).child(month).child("AllAges").child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Match").child(userCountry).child(userCity).child(destination).child(month).child("AllAges").child(userSex).child(travelId), value: travelValues, complition: {})
                
                
                // Update Months
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Months").child("AllCountries").child("AllCities").child(month).child(ageRange).child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Months").child("AllCountries").child("AllCities").child(month).child(ageRange).child(userSex).child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Months").child("AllCountries").child("AllCities").child(month).child("AllAges").child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Months").child("AllCountries").child("AllCities").child(month).child("AllAges").child(userSex).child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Months").child(userCountry).child("AllCities").child(month).child(ageRange).child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Months").child(userCountry).child("AllCities").child(month).child(ageRange).child(userSex).child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Months").child(userCountry).child(userCity).child(month).child(ageRange).child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Months").child(userCountry).child(userCity).child(month).child(ageRange).child(userSex).child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Months").child(userCountry).child("AllCities").child(month).child("AllAges").child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Months").child(userCountry).child("AllCities").child(month).child("AllAges").child(userSex).child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Months").child(userCountry).child(userCity).child(month).child("AllAges").child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Months").child(userCountry).child(userCity).child(month).child("AllAges").child(userSex).child(travelId), value: travelValues, complition: {})
                
                
                // Update AllTravels
                Request.updateChildValue(reference: Request.ref.child("Travels").child("AllTravels").child("AllCountries").child("AllCities").child(ageRange).child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("AllTravels").child("AllCountries").child("AllCities").child(ageRange).child(userSex).child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("AllTravels").child("AllCountries").child("AllCities").child("AllAges").child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("AllTravels").child("AllCountries").child("AllCities").child("AllAges").child(userSex).child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("AllTravels").child(userCountry).child("AllCities").child(ageRange).child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("AllTravels").child(userCountry).child("AllCities").child(ageRange).child(userSex).child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("AllTravels").child(userCountry).child(userCity).child(ageRange).child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("AllTravels").child(userCountry).child(userCity).child(ageRange).child(userSex).child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("AllTravels").child(userCountry).child("AllCities").child("AllAges").child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("AllTravels").child(userCountry).child("AllCities").child("AllAges").child(userSex).child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("AllTravels").child(userCountry).child(userCity).child("AllAges").child("AllSex").child(travelId), value: travelValues, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("AllTravels").child(userCountry).child(userCity).child("AllAges").child(userSex).child(travelId), value: travelValues, complition: {})
                
                self.navigationController?.dismiss(animated: true, completion: nil)
                SearchTableViewController.delegate = nil
            })
        } else {
            if destination == nil {
                MessageBox.showMessage(parent: self, title: NSLocalizedString("Please select country", comment: "Please select country"), message: "")
            } else if monthTextField.text == "" {
                MessageBox.showMessage(parent: self, title: NSLocalizedString("Please select month", comment: "Please select month"), message: "")
            }
        }
    }
    
    func getSearchResult(name: String?, result: (String, String)) {
        self.destination = result.1
        selectButton.setTitle(result.1, for: .normal)
    }
    
    func setTextField() {
        
        let pickerView = MonthPickerView()
        self.monthNumber = String(pickerView.currentMonth)
        self.monthString = MonthPickerView.months[pickerView.currentMonth - 1]
        
        pickerView.onDateSelected = { (monthInt: Int, monthString: String) in
            self.monthNumber = String(monthInt)
            self.monthString = monthString
        }
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolBar.setItems([doneButton], animated: false)
        monthTextField.inputAccessoryView = toolBar
        monthTextField.inputView = pickerView
    }
    
    func donePressed() {
        monthTextField.text = monthString
        self.view.endEditing(true)
    }
    
}
