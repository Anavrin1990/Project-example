//
//  Travel.swift
//  TravelTogether
//
//  Created by Dmitry on 06.07.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation

struct Travel {
    
    var destination: String?
    var month: Int?
    var createDate: Int?
    var country: String?
    var city: String?
    var name: String?
    var birthday: String?
    var icon: String?
    var uid: String?
}

extension Travel {

    init (dictionary: [String : Any]) {

        self.destination = dictionary["destination"] as? String
        self.month = dictionary["month"] as? Int
        self.createDate = dictionary["createdate"] as? Int
        self.country = dictionary["country"] as? String
        self.city = dictionary["city"] as? String
        self.name = dictionary["name"] as? String
        self.birthday = dictionary["birthday"] as? String
        self.icon = dictionary["icon"] as? String
        self.uid = dictionary["uid"] as? String
    }

}
