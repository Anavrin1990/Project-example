//
//  ParamsDataPicker.swift
//  TravelTogether
//
//  Created by Dmitry on 04.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit

protocol ParamsDatePickerDelegate {
    func onDoneClick(name: String, localDate: String)
}

class ParamsDatePicker: ParamsAbstract, ParamsViewsProtocol {
    
    let datePicker = UIDatePicker()
    let monthPicker = MonthPickerView()
    var dateValue: String?
    var monthValue: Int?
    var onlyMonth = false
    
    static var delegate: ParamsDatePickerDelegate?
    
    override func setTextField() {
        super.setTextField()
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolBar.setItems([doneButton], animated: false)
        textField.inputAccessoryView = toolBar
        if onlyMonth {
            textField.inputView = monthPicker
            monthValue = monthPicker.currentMonth
            self.textField.text = monthPicker.months[monthPicker.currentMonth - 1]
        } else {
            datePicker.datePickerMode = .date
            textField.inputView = datePicker
        }
    }
    
    func donePressed() {
        if onlyMonth {
            monthPicker.onDateSelected = { (monthInt: Int, monthString: String) in
                self.textField.text = monthString
                self.monthValue = monthInt
            }
        } else {
            customDateFormatter.dateStyle = .medium
            customDateFormatter.timeStyle = .none
            textField.text = customDateFormatter.string(from: datePicker.date)
            customDateFormatter.dateStyle = .short
            customDateFormatter.dateFormat = "dd.MM.yyyy"
            dateValue = customDateFormatter.string(from: datePicker.date)
        }
        self.parrent?.view.endEditing(true)        
        ParamsDatePicker.delegate?.onDoneClick(name: name!, localDate: textField.text ?? "")
    }
    
    static func initFromNib() -> ParamsDatePicker {
        return Bundle.main.loadNibNamed("ParamsDatePicker", owner: self, options: nil)?.first as! ParamsDatePicker
    }
    
    func setView(placeholder: String?, parrent: UIViewController, name: String, rawValue: String?) {
        setAbstractView(placeholder: placeholder, parrent: parrent, name: name)
    }
    
    func showHide() {
        abstractShowHide()
    }
    
    func hide() {
        abstractHide()
    }
    
    func getValue(complition: @escaping (String?, AnyHashable?, String?) -> ()) {
        let rawValue: AnyHashable? = onlyMonth ? monthValue : dateValue
        complition(name, rawValue, textField.text)
    }
    
    
    
    
    
    

}
