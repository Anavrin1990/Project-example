//
//  TravelViewController.swift
//  TravelTogether
//
//  Created by Dmitry on 24.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit

class TravelViewController: UIViewController, SearchTableViewDelegate {
    
    var country: String?
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
        if let country = country, let month = monthNumber, monthTextField.text != "", let uid = User.uid {
            
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyMMddHHmmss"
            
            let stringDate = dateFormatter.string(from: date)
            
            var values = [String : Any]()
            values["destination"] = country
            values["month"] = month
            values["createdate"] = Int(stringDate)
            values["icon"] = User.icon            
            values["name"] = User.person?.name
            values["age"] = User.person?.birthdate
            values["uid"] = User.uid
            
            Request.updateChildValue(reference: Request.ref.child("Users").child(uid), value: ["hasTravel" : true], complition: {
//                Request.updateChildValue(reference: Request.ref.child("Criteria").child("destination").childByAutoId(), value: ["destination" : country, "uid" : User.uid!], complition: {})
//                Request.updateChildValue(reference: Request.ref.child("Criteria").child("month").childByAutoId(), value: ["month" : month, "uid" : User.uid!], complition: {})
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Countries").child(country).childByAutoId(), value: values, complition: {})
                Request.updateChildValue(reference: Request.ref.child("Travels").child("Months").child(month).childByAutoId(), value: values, complition: {})
                Request.updateChildValue(reference: Request.ref.child("Travels").child("All").childByAutoId(), value: values, complition: {})
                self.navigationController?.dismiss(animated: true, completion: nil)
                SearchTableViewController.delegate = nil
            })
        } else {
            if country == nil {
                MessageBox.showMessage(parent: self, title: NSLocalizedString("Please select country", comment: "Please select country"), message: "")
            } else if monthTextField.text == "" {
                MessageBox.showMessage(parent: self, title: NSLocalizedString("Please select month", comment: "Please select month"), message: "")
            }
        }
        
    }
   
    
    func getSearchResult(result: (String, String), index: Int?) {
        self.country = result.1
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
