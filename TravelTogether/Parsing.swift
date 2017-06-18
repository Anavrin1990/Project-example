////
////  Parsing.swift
////  PaperModels
////
////  Created by Dmitry on 02.04.17.
////  Copyright © 2017 Dmitry. All rights reserved.
////
//
//import Foundation
//import SwiftyJSON
//import FirebaseDatabase
//
//class Parsing {
//    
//    static var modelsArray = [Model]()
//    
//    // Первый запрос
//    static func firstRequestParse (_ snapshot: FIRDataSnapshot?, complition: @escaping (_ modelsArray: [Model]) -> ()) {
//        modelsArray = []
//        
//        if let snap = snapshot?.value as? NSDictionary {
//            let json = JSON(snap)
//            
//            for value in json {
//                let model = Model(position: value.1["pos"].intValue, name: value.1["name"].stringValue, mainImage: value.1["mainImage"].stringValue, infoImage1: value.1["infoImage1"].stringValue, infoImage2: value.1["infoImage2"].stringValue, infoImage3: value.1["infoImage3"].stringValue,infoImage4: value.1["infoImage4"].stringValue, category: value.1["category"].stringValue, difficulty: value.1["difficulty"].intValue, downloads: value.1["downloads"].intValue, likes: value.1["likes"].intValue, pdf: value.1["pdf"].boolValue, views: value.1["views"].intValue, pdo: value.1["pdo"].boolValue, toPrint: value.1["toPrint"].intValue, scale: value.1["scale"].stringValue, instruction: value.1["instruction"].boolValue, source: value.1["source"].stringValue, sourceName: value.1["sourceName"].stringValue, zip: value.1["zip"].stringValue)
//                DispatchQueue.main.async {
//                    self.modelsArray.append(model)
//                    complition(self.modelsArray)
//                }
//                
//            }
//            
//        } else if let snap = snapshot?.value as? NSArray {
//            
//            let json = JSON(snap).arrayValue
//            
//            for value in json {
//                if value["name"] != JSON.null {
//                    let model = Model(position: value["pos"].intValue, name: value["name"].stringValue, mainImage: value["mainImage"].stringValue, infoImage1: value["infoImage1"].stringValue, infoImage2: value["infoImage2"].stringValue, infoImage3: value["infoImage3"].stringValue,infoImage4: value["infoImage4"].stringValue, category: value["category"].stringValue, difficulty: value["difficulty"].intValue, downloads: value["downloads"].intValue, likes: value["likes"].intValue, pdf: value["pdf"].boolValue, views: value["views"].intValue, pdo: value["pdo"].boolValue, toPrint: value["toPrint"].intValue, scale: value["scale"].stringValue, instruction: value["instruction"].boolValue, source: value["source"].stringValue, sourceName: value["sourceName"].stringValue, zip: value["zip"].stringValue)
//                    DispatchQueue.main.async {
//                        self.modelsArray.append(model)
//                        complition(self.modelsArray)
//                    }
//                    
//                }
//            }
//        } else {
//            DispatchQueue.main.async {
//                self.modelsArray = []
//                complition(self.modelsArray)
//            }
//        }
//    }
//    
//    // Следующие запросы
//    static func nextRequestParse (_ snapshot: FIRDataSnapshot?, complition: @escaping (_ modelsArray: [Model]) -> ()) {
//        
//        var preArray = [Model]()
//        
//        if let snap = snapshot?.value as? NSDictionary {
//            let json = JSON(snap)
//            
//            for value in json {
//                let model = Model(position: value.1["pos"].intValue, name: value.1["name"].stringValue, mainImage: value.1["mainImage"].stringValue, infoImage1: value.1["infoImage1"].stringValue, infoImage2: value.1["infoImage2"].stringValue, infoImage3: value.1["infoImage3"].stringValue,infoImage4: value.1["infoImage4"].stringValue, category: value.1["category"].stringValue, difficulty: value.1["difficulty"].intValue, downloads: value.1["downloads"].intValue, likes: value.1["likes"].intValue, pdf: value.1["pdf"].boolValue, views: value.1["views"].intValue, pdo: value.1["pdo"].boolValue, toPrint: value.1["toPrint"].intValue, scale: value.1["scale"].stringValue, instruction: value.1["instruction"].boolValue, source: value.1["source"].stringValue, sourceName: value.1["sourceName"].stringValue, zip: value.1["zip"].stringValue)
//                preArray.append(model)
//                preArray.sort (by: {$0.position < $1.position})
//            }
//            preArray.reverse()
//            complition(preArray)
//            
//        } else if let snap = snapshot?.value as? NSArray {
//            
//            let json = JSON(snap).arrayValue
//            
//            for value in json {
//                if value["name"] != JSON.null {
//                    let model = Model(position: value["pos"].intValue, name: value["name"].stringValue, mainImage: value["mainImage"].stringValue, infoImage1: value["infoImage1"].stringValue, infoImage2: value["infoImage2"].stringValue, infoImage3: value["infoImage3"].stringValue,infoImage4: value["infoImage4"].stringValue, category: value["category"].stringValue, difficulty: value["difficulty"].intValue, downloads: value["downloads"].intValue, likes: value["likes"].intValue, pdf: value["pdf"].boolValue, views: value["views"].intValue, pdo: value["pdo"].boolValue, toPrint: value["toPrint"].intValue, scale: value["scale"].stringValue, instruction: value["instruction"].boolValue, source: value["source"].stringValue, sourceName: value["sourceName"].stringValue, zip: value["zip"].stringValue)
//                    preArray.append(model)
//                }
//            }
//            preArray.reverse()
//            complition(preArray)
//        }
//    }
//    
//    // Первый запрос (equal)
//    static func equalRequestParse (_ snapshot: FIRDataSnapshot?, complition: @escaping (_ modelsArray: Model) -> ()) {
//        
//        if let snap = snapshot?.value as? NSDictionary {
//            let position = snap["pos"] as? Int ?? 0
//            let name = snap["name"] as? String ?? ""
//            let mainImage = snap["mainImage"] as? String ?? ""
//            let infoImage1 = snap["infoImage1"] as? String ?? ""
//            let infoImage2 = snap["infoImage2"] as? String ?? ""
//            let infoImage3 = snap["infoImage3"] as? String ?? ""
//            let infoImage4 = snap["infoImage4"] as? String ?? ""
//            let category = snap["category"] as? String ?? ""
//            let difficulty = snap["difficulty"] as? Int ?? 0
//            let downloads = snap["downloads"] as? Int ?? 0
//            let likes = snap["likes"] as? Int ?? 0
//            let pdf = snap["pdf"] as? Bool ?? false
//            let views = snap["views"] as? Int ?? 0
//            let pdo = snap["pdo"] as? Bool ?? false
//            let toPrint = snap["toPrint"] as? Int ?? 0
//            let scale = snap["scale"] as? String ?? ""
//            let instruction = snap["instruction"] as? Bool ?? false
//            let source = snap["source"] as? String ?? ""
//            let sourceName = snap["sourceName"] as? String ?? ""
//            let zip = snap["zip"] as? String ?? ""
//            let model = Model(position: position, name: name, mainImage: mainImage, infoImage1: infoImage1, infoImage2: infoImage2, infoImage3: infoImage3, infoImage4: infoImage4, category: category, difficulty: difficulty, downloads: downloads, likes: likes, pdf: pdf, views: views, pdo: pdo, toPrint: toPrint, scale: scale, instruction: instruction, source: source, sourceName: sourceName, zip: zip)
//            DispatchQueue.main.async {
//                complition(model)
//            }
//        }
//    }
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//}
