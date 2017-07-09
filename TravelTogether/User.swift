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
    var id: String?
    var name: String?
    var email: String?
    var profileImageUrl: String?
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
    }
}
