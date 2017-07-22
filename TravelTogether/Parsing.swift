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
    
    static func travelsParseFirst (_ snapshot: DataSnapshot?, complition: @escaping (_ travelsArray: [Travel]) -> ()) {
        travelsArray = []
        
        if let snap = snapshot?.value as? NSDictionary {
            let json = JSON(snap)
            for value in json {
                let travel = Travel(destination: value.1["destination"].stringValue,
                                    month: value.1["month"].intValue,
                                    createDate: value.1["createdate"].intValue,
                                    country: value.1["male_createdate"].stringValue,
                                    city: value.1["female_createdate"].stringValue,
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
    
    static func travelsParseSecond (_ snapshot: DataSnapshot?, complition: @escaping (_ travelsArray: [Travel]) -> ()) {
        var preArray = [Travel]()
        
        if let snap = snapshot?.value as? NSDictionary {
            let json = JSON(snap)
            for value in json {
                let travel = Travel(destination: value.1["destination"].stringValue,
                                    month: value.1["month"].intValue,
                                    createDate: value.1["createdate"].intValue,
                                    country: value.1["male_createdate"].stringValue,
                                    city: value.1["female_createdate"].stringValue,
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
