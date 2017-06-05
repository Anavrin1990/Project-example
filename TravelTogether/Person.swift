//
//  Person.swift
//  TravelTogether
//
//  Created by Dmitry on 31.05.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation

struct Person {
    
    static var instance = Person()
    static var profileDict = [Int: String]()
    
    var name: String?
    var sex: String?
    var birthday: String?
    var country: String?
    var city: String?
    var about: String?
    var alcohol: String?
    var smoking: String?
    var familyStatus: String?
    var childs: String?
    var orientation: String?
    var travelKind: String?
    var staing: String?
    var hobbies: [String?]?
    
}

struct Travel {
    var destination: String?
    var destStartDate: String?
    var destEndDate: String?
}


