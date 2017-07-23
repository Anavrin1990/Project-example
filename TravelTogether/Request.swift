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
import FirebaseInstanceID
import FirebaseMessaging
import Alamofire
import SwiftyJSON


class Request {
    
    static var ref = Database.database().reference()
    static var storageRef = Storage.storage().reference()
    
    static func getJSON (url: String?, completion: @escaping (_ JSON: JSON) -> ())  {
        guard let url = url else {return}
        guard url != "" else {return}
        request(url).responseJSON { (response) in
            let result = response.result
            if result.error == nil {
                let json = JSON(result.value as Any)
                completion(json)
                if showLogs {print ("------GET JSON ANSWER -> \(url)\n\(json)")}
            } else {
                if showLogs { print ("------GET JSON ERROR -> \(url)\n\(result.error?.localizedDescription as Any)")}
            }
        }
        if showLogs {print ("------GET JSON REQUEST -> \(url)")}
    }
    
    // Получить изображение
    static func getImage (url: String?, completion: @escaping (_ data: Data?) -> ())  {
        guard let url = url else {return}
        guard url != "" else {return}
        request(url).responseData { (data) in
            if showLogs {print ("------GET IMAGE ANSWER -> \(url)\n\(data.data as Any)")}
            completion(data.data)
        }
        if showLogs {print ("------GET IMAGE REQUEST -> \(url)")}
    }
    
    // Загрузка медиа
    static func storagePutData (reference: StorageReference, data: Data, completion: @escaping (_ snapshot: StorageMetadata?, _ error: Error?) -> ()) {
        
        reference.putData(data, metadata: nil) { (metadata, error) in
            if error != nil {
                completion(nil, error)
                if showLogs {print ("------STORAGE PUT ERROR -> \(reference)\n\(error?.localizedDescription as Any)")}
            } else {
                completion(metadata, nil)
                if showLogs {print ("------STORAGE PUT COMPLETED -> \(reference)")}
            }
        }
        if showLogs {print ("------STORAGE PUT DATA -> \(reference)")}
    }
    
    // Обновление значения
    static func updateChildValue(reference: DatabaseReference, value: [AnyHashable : Any], completion: @escaping () ->()) {
        
        reference.updateChildValues(value) { (error, success) in
            if error != nil {
                if showLogs {print ("------UPDATE ERROR -> \(reference.ref)\n\(error?.localizedDescription as Any)")}
            } else {
                completion()
                if showLogs {print ("------UPDATE COMPLETED -> \(reference.ref)")}
            }
        }
        if showLogs {print ("------UPDATE REQUEST -> \(reference.ref)")}
    }
    
    // Сингл запрос
    static func singleRequest(reference: DatabaseQuery, type: DataEventType, completion: @escaping (_ snapshot: DataSnapshot?, _ error: Error?) -> Void) {
        
        reference.observeSingleEvent(of: type, with: { (snapshot) in
            completion(snapshot, nil)
            if showLogs {print ("------SINGLE ANSWER -> \(reference.ref)\n\(snapshot)")}
        }) { (error) in
            completion(nil, error)
            if showLogs {print ("------SINGLE ANSWER ERROR -> \(reference.ref)\n\(error.localizedDescription)")}
        }
        if showLogs {print ("------SINGLE REQUEST -> \(reference.ref)")}
    }
    
    // Наблюдающий запрос
    static func observeRequest(reference: DatabaseQuery, type: DataEventType, completion: @escaping (_ snapshot: DataSnapshot?, _ error: Error?) -> Void) {
        
        reference.observe(type, with: { (snapshot) in
            completion(snapshot, nil)
            if showLogs {print ("------OBSERVE ANSWER -> \(reference.ref)\n\(snapshot)")}
        }) { (error) in
            completion(nil, error)
            if showLogs {print ("------OBSERVE ANSWER ERROR -> \(reference.ref)\n\(error.localizedDescription)")}
        }
        if showLogs {print ("------OBSERVE REQUEST -> \(reference.ref)")}
    }
    
    static func removeValue(reference: DatabaseReference, completion: @escaping () -> Void) {
        reference.removeValue { (error, ref) in
            if error == nil {
                completion()
                if showLogs {print ("------REMOVE COMPLITED -> \(reference.ref)")}
            } else {
                if showLogs {print ("------REMOVE ERROR -> \(reference.ref)\n\(error?.localizedDescription as Any)")}
            }
        }
    }
    
    // Update online/offline
    static func updateStatus(_ status: UserStatus) {
        guard let uid = User.uid else {return}
        let currentDate = String(Int(Date().timeIntervalSince1970))
        Request.updateChildValue(reference: Request.ref.child("Users").child(uid), value: ["status" : status.rawValue + "_" + currentDate], completion: {})
    }
    
    // Юзер инфо
    static func getUserInfo(completion: @escaping() -> ()) {
        let user = Auth.auth().currentUser
        if let user = user {
            if user.email != nil, user.email != "" {
                User.email = user.email
            }
            User.uid = user.uid
            Request.singleRequest(reference: Request.ref.child("Users").child(User.uid!).queryOrderedByKey(), type: .value, completion: { (snapshot, error) in
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
                    User.countryId = json["countryId"].stringValue
                    User.firstTravel = json["firstTravel"].stringValue
                    User.secondTravel = json["secondTravel"].stringValue
                    User.thirdTravel = json["thirdTravel"].stringValue
                    User.registrationDate = json["registrationDate"].stringValue
                    
                    completion()
                    if showLogs {print ("------GET USER INFO SUCCESS\n\(json)")}
                } else {
                    completion()
                    if showLogs {print ("------GET USER INFO ERROR\n\(error?.localizedDescription as Any)")}
                }
            })
        } else {
            if showLogs {print ("------NOT AUTHORIZED")}
            completion()
        }
        if showLogs {print ("------GET USER INFO REQUEST")}
    }    
    
    static func removeAllObservers(_ reference: [DatabaseReference?]) {
        reference.forEach { (ref) in
            ref?.removeAllObservers()
        }
    }
    
    static func postToken(_ token: String? = nil) {
        guard let token = token ?? Messaging.messaging().fcmToken else {return}
        guard let uid = User.uid else {return}
        Request.updateChildValue(reference: Request.ref.child("Users").child(uid), value: ["fcmToken" : token ], completion: {})
        print ("fcmToken set -> \(token)")       
    }
    
    static func logOut(completion: @escaping() -> ()) {
        MainViewController.needCheckAuth = true
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            Request.updateStatus(.offline)
            User.email = nil
            User.uid = nil            
            completion()
            if showLogs {print ("SING OUT SUCCESS")}
        } catch let signOutError as NSError {
            if showLogs {print ("Error signing out: %@", signOutError)}
        }
    }
    
}
