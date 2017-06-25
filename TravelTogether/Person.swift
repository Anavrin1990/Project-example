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
    static var profileDict = [Int: (String?, String?)]()
    
    var name: String?
    var sex: String?
    var birthdate: String?
    var country: String?
    var city: String?
    var about: String?
    var alcohol: String?
    var smoking: String?
    var familyStatus: String?
    var childs: String?
    var orientation: String?
}

struct Travel {
    
    static var instance = Travel()
    
    var destination: String?
    var month: String?
    var createDate: String?
    var name: String?
    var age: String?
    var icon: String?
}






