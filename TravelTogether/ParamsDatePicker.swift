//
//  ParamsDataPicker.swift
//  TravelTogether
//
//  Created by Dmitry on 04.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit

class ParamsDatePicker: ParamsAbstract {
    
    let datePicker = UIDatePicker()
    
    override func setTextField() {
        super.setTextField()
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolBar.setItems([doneButton], animated: false)
        textField.inputAccessoryView = toolBar
        datePicker.datePickerMode = .date
        textField.inputView = datePicker
    }
    
    func donePressed() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        self.parrent?.view.endEditing(true)
        textField.text = dateFormatter.string(from: datePicker.date)
    }
    
    static func initFromNib() -> ParamsDatePicker {
        return Bundle.main.loadNibNamed("ParamsDataPicker", owner: self, options: nil)?.first as! ParamsDatePicker
    }    
    
    
    
    
    
    

}
