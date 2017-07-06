//
//  Travel.swift
//  TravelTogether
//
//  Created by Dmitry on 06.07.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation

struct Travel {
    
    static var instance = Travel()
    
    var destination: String?
    var month: Int?
    var createDate: Int?
    var male_createdate: Int?
    var female_createdate: Int?
    var name: String?
    var birthday: String?
    var icon: String?
}
