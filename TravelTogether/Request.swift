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
        print ("Get JSON")
    }
    
    // Получить изображение
    static func getImage (url: String?, complition: @escaping (_ data: Data?) -> ())  {
        guard let url = url else {return}
        guard url != "" else {return}
        request(url).responseData { (data) in
            complition(data.data)
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
        print ("Storage put data")
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
        print ("Update child value")
    }
    
    // Узнать последний индекс
    static func requestSingleByChildLastIndex (reference: FIRDatabaseReference, child: String, complition: @escaping (_ snapshot: FIRDataSnapshot?, _ error: Error?) -> ()) {
        
        reference.queryOrdered(byChild: child).queryLimited(toFirst: 1).observeSingleEvent(of: .value, with: { (snapshot) in
            complition(snapshot, nil)
        }) { (error) in
            complition(nil, error)
        }
        print ("Request last index")        
    }
    
    static func requestSingleFirstByKey (reference: FIRDatabaseReference, limit: UInt?, complition: @escaping (_ snapshot: FIRDataSnapshot?, _ error: Error?) -> ()) {
        
        if limit == nil {
            reference.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                complition(snapshot, nil)
            }) { (error) in
                complition(nil, error)
            }
        } else {
            reference.queryOrderedByKey().queryLimited(toLast: limit!).observeSingleEvent(of: .value, with: { (snapshot) in
                complition(snapshot, nil)
            }) { (error) in
                complition(nil, error)
            }
        }
        print ("First single request (byKey)")
        
    }
    
    static func requestSingleFirstByChild (reference: FIRDatabaseReference, child: String, limit: UInt?, complition: @escaping (_ snapshot: FIRDataSnapshot?, _ error: Error?) -> ()) {
        
        if limit == nil {
            reference.queryOrdered(byChild: child).observeSingleEvent(of: .value, with: { (snapshot) in
                complition(snapshot, nil)
            }) { (error) in
                complition(nil, error)
            }
        } else {
            reference.queryOrdered(byChild: child).queryLimited(toLast: limit!).observeSingleEvent(of: .value, with: { (snapshot) in
                complition(snapshot, nil)
            }) { (error) in
                complition(nil, error)
            }
        }
        print ("First single request (byChild)")
    }
    
    static func requestSingleNextByChild<T> (reference: FIRDatabaseReference, child: String, ending: T, limit: UInt?, complition: @escaping (_ snapshot: FIRDataSnapshot?, _ error: Error?) -> ()) {
        
        if limit == nil {
            reference.queryOrdered(byChild: child).queryEnding(atValue: ending).observeSingleEvent(of: .value, with: { (snapshot) in
                complition(snapshot, nil)
            }) { (error) in
                complition(nil, error)
            }            
        } else {
            reference.queryOrdered(byChild: child).queryEnding(atValue: ending).queryLimited(toLast: limit!).observeSingleEvent(of: .value, with: { (snapshot) in
                complition(snapshot, nil)
            }) { (error) in
                complition(nil, error)
            }
        }
        print ("Next single request (byChild)")
    }
    
    static func requestSearchEqual (reference: FIRDatabaseReference, equal: String, complition: @escaping (_ snapshot: FIRDataSnapshot?, _ error: Error?, _ ref: FIRDatabaseReference?) -> ()) {        
        reference.queryOrderedByKey().queryEqual(toValue: equal).observeSingleEvent(of: .value, with: { (snapshot) in
            complition(snapshot, nil, reference)
        }) { (error) in
            complition(nil, error, nil)
        }
        print ("Request search equal")
    }
    
    // Юзер инфо
    static func getUserInfo(complition: @escaping() -> ()) {
        let user = FIRAuth.auth()?.currentUser
        if let user = user {
            if user.email != nil, user.email != "" {
                User.email = user.email
            }
            User.uid = user.uid
            Request.requestSingleFirstByKey(reference: Request.ref.child("Users").child(User.uid!), limit: nil, complition: { (snapshot, error) in
                guard error == nil else {return}
                if let snap = snapshot?.value as? NSDictionary {
                    let json = JSON(snap)
                    let person = Person(name: json["name"].stringValue,
                                        sex: json["sex"].stringValue,
                                        birthday: json["birthday"].stringValue,
                                        country: json["country"].stringValue,
                                        city: json["city"].stringValue,
                                        about: json["about"].stringValue,
                                        alcohol: json["alcohol"].stringValue,
                                        smoking: json["smoking"].stringValue,
                                        familyStatus: json["familyStatus"].stringValue,
                                        childs: json["childs"].stringValue,
                                        orientation: json["orientation"].stringValue)
                    User.person = person
                    User.icon = json["icon"].stringValue
                    User.email = json["email"].stringValue
                    User.travelsCount = json["travelsCount"].intValue
                    complition()                    
                } else {
                    complition()
                }
            })
        } else {
            complition()
        }
        print ("Get user info")
    }
    
    static func logOut(complition: @escaping() -> ()) {
        MainViewController.needCheckAuth = true
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            User.email = nil
            User.uid = nil
            complition()
            print ("Sign out succes")
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
}
