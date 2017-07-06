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
    
    func toSex() -> String? {
        if self == "createdate" {
            return NSLocalizedString("All", comment: "All")
        }
        if self == "male_createdate" {
            return NSLocalizedString("Male", comment: "Male")
        }
        if self == "female_createdate" {
            return NSLocalizedString("Female", comment: "Female")
        }
        return nil
    }
}

extension Int {
    func getMonth () -> String? {
        if self <= 12, self != 0 {
            return DateFormatter().monthSymbols[self - 1]
        }
        return nil
        
    }
}







