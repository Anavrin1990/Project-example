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
}

struct Travel {
    
    static var instance = Travel()
    
    var destination: String?
    var month: Int?
    var createDate: Int?
    var name: String?
    var birthday: String?
    var icon: String?
}






