//
//  SearchViewController.swift
//  TravelTogether
//
//  Created by Dmitry on 01.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit
import FirebaseDatabase
var ref = FIRDatabase.database().reference()
class SearchViewController: UIViewController {
    
    @IBOutlet weak var alcReg: UITextField!
    @IBOutlet weak var smokReg: UITextField!
    @IBOutlet weak var sexReg: UITextField!
    @IBOutlet weak var countReg: UITextField!
    @IBOutlet weak var nameReg: UITextField!
    @IBOutlet weak var alcFetch: UITextField!
    @IBOutlet weak var smokFetch: UITextField!
    @IBOutlet weak var sexFetch: UITextField!
    @IBOutlet weak var countFetch: UITextField!
    @IBOutlet weak var nameFetch: UITextField!
    
    var textFieldArray = [UITextField]()
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldArray.append(alcReg)
        textFieldArray.append(smokReg)
        textFieldArray.append(sexReg)
        textFieldArray.append(countReg)
        textFieldArray.append(nameReg)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func Register(_ sender: Any) {
        index += 1
        var i = 0
        let dict = [
            "Alcohol" : alcReg.text?.toBool(),
            "Smoking" : smokReg.text?.toBool(),
            "Sex" : sexReg.text?.toBool(),
            "Country" : countReg.text,
            "Name" : nameReg.text
            ] as [String : Any]
        ref.child("Person").child(String(index)).updateChildValues(dict) { (error, success) in
            if error != nil {
                print (error?.localizedDescription as Any)
            } else {
                print ("Super")
                
                for t in self.textFieldArray {
                    let value: Any = i <= 2 ? t.text?.toBool() : t.text!
                    ref.child("Criteria").child(t.placeholder!).child(String(self.index)).updateChildValues([t.placeholder!: value], withCompletionBlock: { (error, success) in
                        if error != nil {
                            print (error?.localizedDescription as Any)
                        } else {
                            print ("Puper")
                        }
                    })
                    i += 1
                }
            }
            
        }
        
    }
    
    @IBAction func Fetch(_ sender: Any) {
        var array = [String]()
        var resultArray = [String]()
        ref.child("Criteria").child("Alcohol").queryOrdered(byChild: "Alcohol").queryEqual(toValue: alcFetch.text?.toBool()).observe(.childAdded, with: { (snap) in
            array.append(snap.key)
            for i in array {
                ref.child("Criteria").child("Sex").queryOrderedByKey().queryEqual(toValue: i).observe(.childAdded, with: { (snapshot) in
                    if let snap = snapshot.value as? NSDictionary {
                        let q = snap["Sex"] as! Bool
                        if q == self.sexFetch.text!.toBool() {
                            resultArray.append(snapshot.key)
                            print (resultArray)
                        }
                    }
                })
                
            }
            
        })
        
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension String {
    func toBool() -> Bool {
        let result = self == "1"
        return result
    }
}




