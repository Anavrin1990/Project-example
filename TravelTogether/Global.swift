//
//  Global.swift
//  TravelTogether
//
//  Created by Dmitry on 12.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

var imageCache = NSCache<AnyObject, AnyObject>()
let reqLimit: UInt = 15 // Лимит запроса
var countryId = ""

let spinner: UIActivityIndicatorView = {
    let spin = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    spin.translatesAutoresizingMaskIntoConstraints = false
    spin.color = UIColor.darkGray
    spin.hidesWhenStopped = true
    return spin
}()

let customDateFormatter : DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy"
    return formatter
}()

func addSpinner(_ view: UIView) {
    
    view.addSubview(spinner)
    NSLayoutConstraint(item: spinner, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: spinner, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 0.85, constant: 0).isActive = true
}

var emptyCellCountryName = ("", NSLocalizedString("Not filled", comment: "Not filled"))
func searchCountries (_ complition: @escaping (_ content: [(String, [(String, String)])]) -> ()) {
    countryId = ""
    Request.getJSON(url: "https://api.vk.com/api.php?oauth=1&method=database.getCountries&v=5.65&need_all=1&lang=en&count=1000") { (json) in
        var countriesArray = [emptyCellCountryName]
        let countries = json["response"]["items"].arrayValue
        for c in countries {
            let country = (c["id"].stringValue, c["title"].stringValue)
            countriesArray.append(country)
        }
        let result = (NSLocalizedString("Countries", comment: "Countries"), countriesArray)
        complition([result])
    }
}

func searchCities (_ complition: @escaping (_ content: [(String, [(String, String)])]) -> ()) {
    Request.getJSON(url: "https://api.vk.com/api.php?oauth=1&method=database.getCities&v=5.5&country_id=\(countryId)&lang=en&count=1000") { (json) in
        var citiesArray = [("", NSLocalizedString("Not filled", comment: "Not filled"))]
        let cities = json["response"]["items"].arrayValue
        for c in cities {
            let city = (c["id"].stringValue, c["title"].stringValue)
            citiesArray.append(city)
        }
        let result = (NSLocalizedString("Nearest city", comment: "Nearest city"), citiesArray)
        complition([result])
    }
}

func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
    var i = 0
    return AnyIterator {
        let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
        if next.hashValue != i { return nil }
        i += 1
        return next
    }
}
