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
    
    func getSearchResult(name: String?, result: (String, String)) {
        self.destination = result.1
        selectButton.setTitle(result.1, for: .normal)
    }
    
    func setTextField() {
        
        let pickerView = MonthPickerView(fromCurrent: false)
                
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
