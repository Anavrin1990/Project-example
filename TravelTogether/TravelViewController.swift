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

    @IBAction func selectButton(_ sender: Any) {
        let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchTableViewController") as! SearchTableViewController
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
            
            var values = [String : Any]()
            values["destination"] = destination
            values["month"] = month
            values["createdate"] = Int(stringDate)
            values["icon"] = User.icon            
            values["name"] = User.person?.name
            values["birthday"] = User.person?.birthday
            values["uid"] = User.uid            
            values["sex"] = User.person?.sex
            values["\(User.person!.sex!)_createdate"] = Int(stringDate)
            
            Request.updateChildValue(reference: Request.ref.child("Users").child(uid), value: ["travelsCount" : (User.travelsCount)! + 1], complition: {
                
                Request.updateChildValue(reference: Request.ref.child("Criteria").child("destination").childByAutoId(), value: ["destination" : destination], complition: {})
                Request.updateChildValue(reference: Request.ref.child("Criteria").child("month").childByAutoId(), value: ["month" : month], complition: {})
                
                
                // Update Destinations
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Destinations").child("AllCountries").child("AllCities").child(destination).child(ageRange).childByAutoId(), value: values, complition: {})
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Destinations").child("AllCountries").child("AllCities").child(destination).child("AllAges").childByAutoId(), value: values, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Destinations").child(User.person!.country!).child("AllCities").child(destination).child(ageRange).childByAutoId(), value: values, complition: {})
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Destinations").child(User.person!.country!).child(User.person!.city!).child(destination).child(ageRange).childByAutoId(), value: values, complition: {})
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Destinations").child(User.person!.country!).child("AllCities").child(destination).child("AllAges").childByAutoId(), value: values, complition: {})
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Destinations").child(User.person!.country!).child(User.person!.city!).child(destination).child("AllAges").childByAutoId(), value: values, complition: {})
                
                
                // Update Match
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Match").child("AllCountries").child("AllCities").child(destination).child(month).child(ageRange).childByAutoId(), value: values, complition: {})
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Match").child("AllCountries").child("AllCities").child(destination).child(month).child("AllAges").childByAutoId(), value: values, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Match").child(User.person!.country!).child("AllCities").child(destination).child(month).child(ageRange).childByAutoId(), value: values, complition: {})
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Match").child(User.person!.country!).child(User.person!.city!).child(destination).child(month).child(ageRange).childByAutoId(), value: values, complition: {})
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Match").child(User.person!.country!).child("AllCities").child(destination).child(month).child("AllAges").childByAutoId(), value: values, complition: {})
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Match").child(User.person!.country!).child(User.person!.city!).child(destination).child(month).child("AllAges").childByAutoId(), value: values, complition: {})
                
                
                // Update Months
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Months").child("AllCountries").child("AllCities").child(month).child(ageRange).childByAutoId(), value: values, complition: {})
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Months").child("AllCountries").child("AllCities").child(month).child("AllAges").childByAutoId(), value: values, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Months").child(User.person!.country!).child("AllCities").child(month).child(ageRange).childByAutoId(), value: values, complition: {})
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Months").child(User.person!.country!).child(User.person!.city!).child(month).child(ageRange).childByAutoId(), value: values, complition: {})
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Months").child(User.person!.country!).child("AllCities").child(month).child("AllAges").childByAutoId(), value: values, complition: {})
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Months").child(User.person!.country!).child(User.person!.city!).child(month).child("AllAges").childByAutoId(), value: values, complition: {})
                
                
                // Update AllTravels
                Request.updateChildValue(reference: Request.ref.child("Travels").child("AllTravels").child("AllCountries").child("AllCities").child(ageRange).childByAutoId(), value: values, complition: {})
                Request.updateChildValue(reference: Request.ref.child("Travels").child("AllTravels").child("AllCountries").child("AllCities").child("AllAges").childByAutoId(), value: values, complition: {})
                
                Request.updateChildValue(reference: Request.ref.child("Travels").child("AllTravels").child(User.person!.country!).child("AllCities").child(ageRange).childByAutoId(), value: values, complition: {})
                Request.updateChildValue(reference: Request.ref.child("Travels").child("AllTravels").child(User.person!.country!).child(User.person!.city!).child(ageRange).childByAutoId(), value: values, complition: {})
                Request.updateChildValue(reference: Request.ref.child("Travels").child("AllTravels").child(User.person!.country!).child("AllCities").child("AllAges").childByAutoId(), value: values, complition: {})
                Request.updateChildValue(reference: Request.ref.child("Travels").child("AllTravels").child(User.person!.country!).child(User.person!.city!).child("AllAges").childByAutoId(), value: values, complition: {})
                
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
        self.monthString = pickerView.months[pickerView.currentMonth - 1]
        
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
