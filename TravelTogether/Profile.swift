//
//  Profile.swift
//  TravelTogether
//
//  Created by Dmitry on 17.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation

enum Profile {
    
    enum Sex: String {
        case male
        case female
        var  localValue: String {
            switch self {
            case .male: return NSLocalizedString("Male", comment: "Male")
            case .female: return NSLocalizedString("Female", comment: "Female")
            }
        }
    }
    enum Alcohol: String {
        case positive
        case negative
        var  localValue: String {
            switch self {
            case .positive: return NSLocalizedString("Positive", comment: "Positive")
            case .negative: return NSLocalizedString("Negative", comment: "Negative")
            }
        }
    }
    enum Smoking: String {
        case positive
        case negative
        var  localValue: String {
            switch self {
            case .positive: return NSLocalizedString("Positive", comment: "Positive")
            case .negative: return NSLocalizedString("Negative", comment: "Negative")
            }
        }
    }
    enum Family: String {
        case single
        case married
        var  localValue: String {
            switch self {
            case .single: return NSLocalizedString("Single", comment: "Single")
            case .married: return NSLocalizedString("Married", comment: "Married")
            }
        }
    }
    enum Childs: String {
        case yes
        case no
        var  localValue: String {
            switch self {
            case .no: return NSLocalizedString("No", comment: "No")
            case .yes: return NSLocalizedString("Yes", comment: "Yes")    
            }
        }
    }
    enum Orientation: String {
        case hetero
        case homo
        case bi
        var  localValue: String {
            switch self {
            case .hetero: return NSLocalizedString("Hetero", comment: "Hetero")
            case .homo: return NSLocalizedString("Homo", comment: "Homo")
            case .bi: return NSLocalizedString("Bi", comment: "Bi")
            }
        }
    }
    enum TravelType: String {
        case active
        case beachRest
        var  localValue: String {
            switch self {
            case .active: return NSLocalizedString("Active", comment: "Active")
            case .beachRest: return NSLocalizedString("Beach rest", comment: "Beach rest")
            }
        }
    }
    enum Staying: String {
        case hotel
        case hostel
        case rent
        var  localValue: String {
            switch self {
            case .hotel: return NSLocalizedString("Hotel", comment: "Hotel")
            case .hostel: return NSLocalizedString("Hostel", comment: "Hostel")
            case .rent: return NSLocalizedString("Rent", comment: "Rent")
            }
        }
    }
    
}
