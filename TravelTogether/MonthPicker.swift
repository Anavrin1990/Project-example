//
//  MonthYearPicker.swift
//  TravelTogether
//
//  Created by Dmitry on 25.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import UIKit

class MonthPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var currentMonth = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.component(.month, from: NSDate() as Date)
    
    static var months = [NSLocalizedString("January", comment: "January"),
                         NSLocalizedString("February", comment: "February"),
                         NSLocalizedString("March", comment: "March"),
                         NSLocalizedString("April", comment: "April"),
                         NSLocalizedString("May", comment: "May"),
                         NSLocalizedString("June", comment: "June"),
                         NSLocalizedString("July", comment: "July"),
                         NSLocalizedString("August", comment: "August"),
                         NSLocalizedString("September", comment: "September"),
                         NSLocalizedString("October", comment: "October"),
                         NSLocalizedString("November", comment: "November"),
                         NSLocalizedString("December", comment: "December")]
    
    var month: Int = 0 {
        didSet {
            selectRow(month-1, inComponent: 0, animated: false)
        }
    }
    
    var onDateSelected: ((_ monthInt: Int, _ monthString: String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonSetup()
    }
    
    func commonSetup() {
        
//        // population months with localized names
//        var months: [String] = []
//        var month = 0
//        for _ in 1...12 {
//            months.append(DateFormatter().monthSymbols[month].capitalized)
//            month += 1
//        }
//        MonthPickerView.months = months
        
        self.delegate = self
        self.dataSource = self
        
        self.selectRow(currentMonth - 1, inComponent: 0, animated: false)        
        
    }
    
    // Mark: UIPicker Delegate / Data Source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return MonthPickerView.months[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return MonthPickerView.months.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let monthInt = self.selectedRow(inComponent: 0)+1
        let monthString = MonthPickerView.months[row]
        
        if let block = onDateSelected {
            block(monthInt, monthString)
        }
        self.month = monthInt
    }
    
}
