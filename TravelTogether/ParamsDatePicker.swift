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
    var dateValue: String?
    
    static var delegate: ParamsDatePickerDelegate?
    
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
        customDateFormatter.dateStyle = .medium
        customDateFormatter.timeStyle = .none
        self.parrent?.view.endEditing(true)
        textField.text = customDateFormatter.string(from: datePicker.date)
        customDateFormatter.dateStyle = .short
        customDateFormatter.dateFormat = "dd.MM.yyyy"
        dateValue = customDateFormatter.string(from: datePicker.date)
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
    
    func getValue(complition: @escaping (String?, String?, String?) -> ()) {
        //Person.profileDict[self.tag] = (dateValue, textField.text)
        complition(name, dateValue, textField.text)
    }
    
    
    
    
    
    

}
