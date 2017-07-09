//
//  Extensions.swift
//  TravelTogether
//
//  Created by Dmitry on 04.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func getImage (url: String?) {
        
        if let cacheImage = imageCache.object(forKey: url as AnyObject) as? UIImage {
            self.image = cacheImage
            return
        }
        Request.getImage(url: url) { (data) in
            guard let imageData = data else {return}
            DispatchQueue.main.async {
                guard let image = UIImage(data: imageData) else {return}
                imageCache.setObject(image, forKey: url as AnyObject)
                self.image = image
            }
        }
    }
}

extension Bool {
    
    func toString() -> String? {
        switch self {
        case true: return NSLocalizedString("Yes", comment: "Yes")
        case false: return NSLocalizedString("No", comment: "No")
        }
    }
}

extension String {
    func getAge () -> String? {
        let birthday = customDateFormatter.date(from: self)
        let now = Date()
        let calendar = Calendar.current
        if let birthday = birthday {
            let ageComponents = calendar.dateComponents([Calendar.Component.year], from: birthday, to: now)
            if let age = ageComponents.year {
                return String(age)
            }
        }
        return nil
    }
    
    func getAgeRange () -> String? {
        if let stringAge = self.getAge() {
            let age = Int(stringAge)!            
            
            if age <= 29 {
                return AgeRange.toThirty.rawValue
            } else if age >= 30, age <= 39 {
                return AgeRange.toForty.rawValue
            } else if age >= 40, age <= 49 {
                return AgeRange.toFifty.rawValue
            } else if age >= 50, age <= 59 {
                return AgeRange.toSixty.rawValue
            } else if age >= 60, age <= 69 {
                return AgeRange.toSeventy.rawValue
            } else {
                return AgeRange.fromSeventy.rawValue
            }
        }
        return nil
    }
    
    func toSex() -> String {
        if self == "createdate" {
            return NSLocalizedString("All", comment: "All")
        }
        if self == "male_createdate" {
            return NSLocalizedString("Male", comment: "Male")
        }
        if self == "female_createdate" {
            return NSLocalizedString("Female", comment: "Female")
        }
        return self
    }
    
    func toCountry() -> String {
        if self == "AllCountries" {
            return NSLocalizedString("All countries", comment: "All countries")
        }
        return self
    }
    
    func toCity() -> String {
        if self == "AllCities" {
            return NSLocalizedString("All cities", comment: "All cities")
        }
        return self
    }
    
    func toMonth() -> String {
        if self == "AllMonths" {
            return NSLocalizedString("All months", comment: "All months")
        }
        if let month = Int(self) {
            if let result = month.getMonth() {
                return result
            }
        }
        return self
    }
    
    func toAgeRange() -> String {
        for range in iterateEnum(AgeRange.self) {
            if self == range.rawValue {
                return range.localValue
            }
        }
        return self
    }
}

extension Int {
    func getMonth () -> String? {
        if self <= 12, self != 0 {
            return MonthPickerView.months[self - 1]
        }
        return nil        
    }
}
extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(_ urlString: String) {
        
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            //download hit an error so lets return out
            if error != nil {
                print(error ?? "")
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    
                    self.image = downloadedImage
                }
            })
            
        }).resume()
    }
    
}






