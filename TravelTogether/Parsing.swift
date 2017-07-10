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
    
    static var travelsArray = [Travel]()
    
    // Первый запрос
    static func usersParse (_ snapshot: FIRDataSnapshot?, complition: @escaping (_ user: User?) -> ()) {
        
        var user: User?
        
        if let snap = snapshot?.value as? NSDictionary {
            let json = JSON(snap).first
            
            let person = Person(name: json?.1["name"].stringValue,
                                sex: json?.1["sex"].stringValue,
                                birthday: json?.1["birthday"].stringValue,
                                country: json?.1["name"].stringValue,
                                city: json?.1["city"].stringValue,
                                about: json?.1["about"].stringValue,
                                alcohol: json?.1["alcohol"].stringValue,
                                smoking: json?.1["smoking"].stringValue,
                                familyStatus: json?.1["familyStatus"].stringValue,
                                childs: json?.1["childs"].stringValue,
                                orientation: json?.1["orientation"].stringValue)
            user = User(email: json?.1["email"].stringValue,
                        uid: json?.1["uid"].stringValue,
                        person: person,
                        icon: json?.1["icon"].stringValue,
                        countryId: json?.1["countryID"].stringValue,                       
                        firstTravel: json?.1["firstTravel"].stringValue,
                        secondTravel: json?.1["secondTravel"].stringValue,
                        thirdTravel: json?.1["thirdTravel"].stringValue)
        }
        complition(user)
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
                                    icon: value.1["icon"].stringValue,
                                    uid: value.1["uid"].stringValue)
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
                                    icon: value.1["icon"].stringValue,
                                    uid: value.1["uid"].stringValue)
                preArray.append(travel)
                
            }
            
            complition(preArray)
        }
    }
    
    
    
    
    
}
