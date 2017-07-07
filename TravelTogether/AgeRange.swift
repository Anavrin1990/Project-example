//
//  AgeRange.swift
//  TravelTogether
//
//  Created by Dmitry on 07.07.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation

enum AgeRange: String {
    
    case AllAges
    case toThirty
    case toForty
    case toFifty
    case toSixty
    case toSeventy
    case fromSeventy
    
    var  localValue: String {
        switch self {
        case .AllAges: return NSLocalizedString("All ages", comment: "All ages")
        case .toThirty: return NSLocalizedString("Up to 30 years old", comment: "Up to 30 years old")
        case .toForty: return NSLocalizedString("30-39 years old", comment: "30-39 years old")
        case .toFifty: return NSLocalizedString("40-49  years old", comment: "40-49 years old")
        case .toSixty: return NSLocalizedString("50-59 years old", comment: "50-59 years old")
        case .toSeventy: return NSLocalizedString("60-69 years old", comment: "60-69 years old")
        case .fromSeventy: return NSLocalizedString("Over 70 years old", comment: "Over 70 years old")
        }
    }
}
