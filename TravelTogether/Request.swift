//
//  Request.swift
//  TravelTogether
//
//  Created by Dmitry on 11.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import Alamofire
import SwiftyJSON

class Request {
    
    static var ref = FIRDatabase.database().reference()
    static var storageRef = FIRStorage.storage().reference()
    
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
    
    static func storagePutData (reference: FIRStorageReference, data: Data, complition: @escaping (_ snapshot: FIRStorageMetadata?, _ error: Error?) -> ()) {
        
        reference.put(data, metadata: nil) { (metadata, error) in
            if error != nil {
                complition(nil, error)
            } else {
                complition(metadata, nil)
            }
        }
    }
    
    // Обновление значения
    static func updateChildValue (reference: FIRDatabaseReference, value: [AnyHashable : Any], complition: @escaping () ->()) {
        
        reference.updateChildValues(value) { (error, success) in
            if error != nil {
                print (error?.localizedDescription as Any)
            } else {
                complition()
            }
        }        
    }
    
    static func requestSingleFirstByKey (reference: FIRDatabaseReference, limit: UInt?, complition: @escaping (_ snapshot: FIRDataSnapshot?, _ error: Error?) -> ()) {
        
        if limit == nil {
            reference.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                complition(snapshot, nil)
            }) { (error) in
                complition(nil, error)
            }
            print ("First single request (byKey)")
        } else {
            reference.queryOrderedByKey().queryLimited(toLast: limit!).observeSingleEvent(of: .value, with: { (snapshot) in
                complition(snapshot, nil)
            }) { (error) in
                complition(nil, error)
            }
            print ("First single request (byKey)")
        }
        
        
    }
    
    static func requestSearchEqual (reference: FIRDatabaseReference, equal: String, complition: @escaping (_ snapshot: FIRDataSnapshot?, _ error: Error?, _ ref: FIRDatabaseReference?) -> ()) {        
        reference.queryOrderedByKey().queryEqual(toValue: equal).observeSingleEvent(of: .value, with: { (snapshot) in
            complition(snapshot, nil, reference)
        }) { (error) in
            complition(nil, error, nil)
        }
    }
    
    // Юзер инфо
    static func getUserInfo() {
        let user = FIRAuth.auth()?.currentUser
        if let user = user {
            User.email = user.email
            User.uid = user.uid
            User.displayName = user.displayName
        }
        
    }
    
}
