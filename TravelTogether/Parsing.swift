//
//  Parsing.swift
//  PaperModels
//
//  Created by Dmitry on 02.04.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import SwiftyJSON
import FirebaseDatabase

class Parsing {
    
    static var personsArray = [Person]()
    static var travelsArray = [Travel]()
    
    // Первый запрос
    static func usersParse (_ snapshot: FIRDataSnapshot?, complition: @escaping (_ personsArray: [Person]) -> ()) {
        personsArray = []
        
        if let snap = snapshot?.value as? NSDictionary {
            let json = JSON(snap)
            for value in json {
                let person = Person(name: value.1["name"].stringValue,
                                    sex: value.1["sex"].stringValue,
                                    birthday: value.1["birthday"].stringValue,
                                    country: value.1["name"].stringValue,
                                    city: value.1["city"].stringValue,
                                    about: value.1["about"].stringValue,
                                    alcohol: value.1["alcohol"].stringValue,
                                    smoking: value.1["smoking"].stringValue,
                                    familyStatus: value.1["familyStatus"].stringValue,
                                    childs: value.1["childs"].stringValue,
                                    orientation: value.1["orientation"].stringValue)
                self.personsArray.append(person)
            }
            complition(self.personsArray)
        } else {
            self.personsArray = []
            complition(self.personsArray)
        }
    }
    
    static func travelsParseFirst (_ snapshot: FIRDataSnapshot?, complition: @escaping (_ travelsArray: [Travel]) -> ()) {
        travelsArray = []
        
        if let snap = snapshot?.value as? NSDictionary {
            let json = JSON(snap)            
            for value in json {
                let travel = Travel(destination: value.1["destination"].stringValue,
                                    month: value.1["month"].intValue,
                                    createDate: value.1["createdate"].intValue,
                                    male_createdate: value.1["male_createdate"].intValue,
                                    female_createdate: value.1["female_createdate"].intValue,
                                    name: value.1["name"].stringValue,
                                    birthday: value.1["birthday"].stringValue,
                                    icon: value.1["icon"].stringValue)
                self.travelsArray.append(travel)
            }
            complition(self.travelsArray)
        } else {
            self.travelsArray = []
            complition(self.travelsArray)
        }
    }
    
    static func travelsParseSecond (_ snapshot: FIRDataSnapshot?, complition: @escaping (_ travelsArray: [Travel]) -> ()) {
        var preArray = [Travel]()
        
        if let snap = snapshot?.value as? NSDictionary {
            let json = JSON(snap)
            for value in json {
                let travel = Travel(destination: value.1["destination"].stringValue,
                                    month: value.1["month"].intValue,
                                    createDate: value.1["createdate"].intValue,
                                    male_createdate: value.1["male_createdate"].intValue,
                                    female_createdate: value.1["female_createdate"].intValue,
                                    name: value.1["name"].stringValue,
                                    birthday: value.1["birthday"].stringValue,
                                    icon: value.1["icon"].stringValue)
                preArray.append(travel)
                
            }
            
            complition(preArray)
        }
    }
    
    
    
    
    
}
