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

let showLogs = true

var imageCache = NSCache<AnyObject, AnyObject>()
let reqLimit: UInt = 15 // Лимит запроса

let spinner: UIActivityIndicatorView = {
    let spin = UIActivityIndicatorView(activityIndicatorStyle: .white)
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

func getCachedImage(url: String?, completion: @escaping (UIImage) -> Void) {
        if let cacheImage = imageCache.object(forKey: url as AnyObject) as? UIImage {
            completion(cacheImage)
            return
        }
        Request.getImage(url: url) { (data) in
            guard let imageData = data else {return}
            DispatchQueue.main.async {
                guard let image = UIImage(data: imageData) else {return}
                imageCache.setObject(image, forKey: url as AnyObject)
                completion(image)
            }
        }
}

func isTodayDate(_ timestamp: NSNumber) -> String {
    var result = ""
    
    let currentDate = Date()
    let messageDate = Date(timeIntervalSince1970: Double(timestamp))
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.yy"
    let currentDay = dateFormatter.string(from: currentDate)
    let messageDay = dateFormatter.string(from: messageDate)
    
    if currentDay == messageDay {
        dateFormatter.dateFormat = "HH:mm"
        result = dateFormatter.string(from: messageDate)
    } else {
        result = dateFormatter.string(from: messageDate)
    }
    return result
}

var emptySearchName = ("", NSLocalizedString("Not filled", comment: "Not filled"))
func searchCountries (_ complition: @escaping (_ content: [(String, [(String, String)])]) -> ()) {
    //countryId = ""
    Request.getJSON(url: "https://api.vk.com/api.php?oauth=1&method=database.getCountries&v=5.65&need_all=1&lang=en&count=1000") { (json) in
        var countriesArray = [emptySearchName]
        if emptySearchName == ("", "") {
            countriesArray = []
        }
        let countries = json["response"]["items"].arrayValue
        for c in countries {
            let country = (c["id"].stringValue, c["title"].stringValue)
            countriesArray.append(country)
        }
        let result = (NSLocalizedString("Countries", comment: "Countries"), countriesArray)
        complition([result])
    }
}

var countryId = UserDefaults.standard.value(forKey: "countryId") as? String ?? ""
func searchCities (_ complition: @escaping (_ content: [(String, [(String, String)])]) -> ()) {
    
    Request.getJSON(url: "https://api.vk.com/api.php?oauth=1&method=database.getCities&v=5.5&country_id=\(countryId)&lang=en&count=1000") { (json) in
        var citiesArray = [emptySearchName]
        if emptySearchName == ("", "") {
            citiesArray = []
        }
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
