//
//  User.swift
//  TravelTogether
//
//  Created by Dmitry on 17.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation

struct User {
    
    static var email: String?
    static var uid: String?
    static var person: Person?
    static var icon: String?    
    static var countryId: String?
    static var firstTravel: String?
    static var secondTravel: String?
    static var thirdTravel: String?
    static var registrationDate: String?
    
    var email: String?
    var uid: String?
    var person: Person?
    var icon: String?
    var countryId: String?    
    var firstTravel: String?
    var secondTravel: String?
    var thirdTravel: String?
    
}

extension User {
    
    init(dictionary: [String: AnyObject]) {
        self.email = dictionary["email"] as? String
        self.uid = dictionary["uid"] as? String
        self.person?.name = dictionary["name"] as? String
        self.icon = dictionary["icon"] as? String       
    }
}
