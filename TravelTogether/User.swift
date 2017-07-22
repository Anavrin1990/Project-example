//
//  User.swift
//  TravelTogether
//
//  Created by Dmitry on 17.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import SwiftyJSON

enum UserStatus: String {
    case online
    case offline
    
    var localValue: String {
        switch self {
        case .online: return NSLocalizedString("Online", comment: "Online")
        case .offline: return NSLocalizedString("last seen ", comment: "last seen ")
        }
    }
    var color: UIColor {
        switch self {
        case .online: return .green
        case .offline: return .clear
        }
    }
}

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
    var status: UserStatus?
    var lastSeen: String?
    var fcmToken: String?
    
}

extension User {
    
    init(dictionary: [String: AnyObject]) {
        
        let person = Person(name: dictionary["name"] as? String,
                            sex: dictionary["sex"] as? String,
                            birthday: dictionary["birthday"] as? String,
                            country: dictionary["name"] as? String,
                            city: dictionary["city"] as? String,
                            about: dictionary["about"] as? String,
                            alcohol: dictionary["alcohol"] as? String,
                            smoking: dictionary["smoking"] as? String,
                            familyStatus: dictionary["familyStatus"] as? String,
                            childs: dictionary["childs"] as? String,
                            orientation: dictionary["orientation"] as? String)
        
        self.email = dictionary["email"] as? String
        self.uid = dictionary["uid"] as? String
        self.icon = dictionary["icon"] as? String
        self.person = person
        self.countryId = dictionary["countryID"] as? String
        self.firstTravel = dictionary["firstTravel"] as? String
        self.secondTravel = dictionary["secondTravel"] as? String
        self.thirdTravel = dictionary["thirdTravel"] as? String
        
        let status = dictionary["status"] as? String
        let statusLastSeen = status?.components(separatedBy: "_")
        self.status = UserStatus(rawValue: statusLastSeen?[0] ?? "Offline")
        self.lastSeen = statusLastSeen?[1]
        self.fcmToken = dictionary["fcmToken"] as? String
    }
}
