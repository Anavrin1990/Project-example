//
//  Request.swift
//  TravelTogether
//
//  Created by Dmitry on 11.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import Alamofire
import SwiftyJSON

class Request {
    
    var ref = FIRDatabase.database().reference()
    
    static func getJSON (url: String?, complition: @escaping (_ JSON: JSON) -> ())  {
        guard let url = url else {return}
        guard url != "" else {return}
        request(url).responseJSON { (response) in
            let result = response.result
            if result.error == nil {
                let json = JSON(result.value as Any)
                complition(json)                
            } else {
                print (result.error?.localizedDescription as Any)
            }
        }
    }
}
