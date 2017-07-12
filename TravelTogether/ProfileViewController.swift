//
//  ProfileViewController.swift
//  TravelTogether
//
//  Created by Dmitry on 03.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    let imagePicker = UIImagePickerController()
    
    var photoArray = [UIImage]()
    let photoArrayNames = ["infoImage1", "infoImage2", "infoImage3", "infoImage4", "infoImage5"]
    var componentsArray = [(header: String, paramKey: String, fields: [ParamsAbstract]?, instantiateVC: UIViewController?)]()
    
    @IBOutlet weak var dropStackView: DropStackView! {
        didSet {
            dropStackView.setDropStackView(self)
            addDropList()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delaysContentTouches = false
        registerForKeyboardNotifications()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func kbWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let kbFrameSize = (userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        scrollView.contentOffset = CGPoint(x: 0, y: kbFrameSize.height)
    }
    
    func kbWillHide() {
        scrollView.contentOffset = CGPoint.zero
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        guard photoArray.count < 5 else {
            MessageBox.showMessage(parent: self, title: NSLocalizedString("Only five photos", comment: "Only five photos"), message: "")
            return
        }
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func nextButton(_ sender: Any) {
        
        let profileDict = dropStackView.getValue()
        
        Person.instance.name = profileDict["name"] as? String
        Person.instance.sex = profileDict["sex"] as? String
        Person.instance.birthday = profileDict["birthday"] as? String
        Person.instance.country = profileDict["country"] as? String
        Person.instance.city = profileDict["city"] as? String
        Person.instance.about = profileDict["about"] as? String
        Person.instance.alcohol = profileDict["alcohol"] as? String
        Person.instance.smoking = profileDict["smoking"] as? String
        Person.instance.familyStatus = profileDict["familyStatus"] as? String
        Person.instance.childs = profileDict["childs"] as? String
        Person.instance.orientation = profileDict["orientation"] as? String        
        
        var userProperties = [AnyHashable : Any]()
        
        let mirror = Mirror(reflecting: Person.instance)
        
        for i in mirror.children.enumerated() {
            if i.1.value as? String == nil || i.1.value as? String == "" || i.1.value as? String == NSLocalizedString("Not filled", comment: "Not filled") {
                MessageBox.showMessage(parent: self, title: componentsArray[i.offset].paramKey, message: NSLocalizedString("Not filled", comment: "Not filled"))
                return
            } else {
                userProperties[i.1.label!] = i.1.value
            }
        }
        if photoArray.isEmpty {
            MessageBox.showMessage(parent: self, title: NSLocalizedString("Please add photos", comment: "Please add photos"), message: "")
            return
        }
        if let uid = User.uid {
            for (k, v) in userProperties {
                Request.updateChildValue(reference: Request.ref.child("Criteria").child(k as! String).child(uid), value: [k : v], complition: {})
            }
            for photo in photoArray.enumerated() {
                if photo.offset == 0 {
                    if let uploadPhoto = UIImageJPEGRepresentation(photo.element, 0.2) {
                        Request.storagePutData(reference: Request.storageRef.child(uid).child("icon"), data: uploadPhoto, complition: { (metadata, error) in
                            guard error == nil else {print (error?.localizedDescription as Any); return}
                            if let imageURL = metadata?.downloadURL()?.absoluteString {
                                Request.updateChildValue(reference: Request.ref.child("Users").child(uid), value: ["icon": imageURL], complition: {})
                            }
                        })
                    }
                }
                if let uploadPhoto = UIImageJPEGRepresentation(photo.element, 0.6) {
                    Request.storagePutData(reference: Request.storageRef.child(uid).child(photoArrayNames[photo.offset]), data: uploadPhoto, complition: { (metadata, error) in
                        guard error == nil else {print (error?.localizedDescription as Any); return}
                        if let imageURL = metadata?.downloadURL()?.absoluteString {
                            Request.updateChildValue(reference: Request.ref.child("Users").child(uid), value: [self.photoArrayNames[photo.offset]: imageURL], complition: {})
                        }
                    })
                }
                
            }
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yy"
            
            let stringDate = dateFormatter.string(from: date)
            userProperties["registrationDate"] = stringDate
            userProperties["uid"] = uid            
            userProperties["countryId"] = countryId
            Request.updateChildValue(reference: Request.ref.child("Users").child(uid), value: userProperties, complition: {
                UserDefaults.standard.set(Person.instance.country, forKey: "countryDefault")
                UserDefaults.standard.set(Person.instance.city, forKey: "cityDefault")
                UserDefaults.standard.synchronize()
                self.navigationController?.dismiss(animated: true, completion: nil)
                SearchTableViewController.delegate = nil
            })            
        }
    }
    
    func addDropList() {
        
        emptySearchName = ("", NSLocalizedString("Not filled", comment: "Not filled"))
        let nameField = ParamsTextField.initFromNib()
        nameField.setView(placeholder: NSLocalizedString("Enter your name", comment: "Enter your name"), parrent: self, name: "name", rawValue: nil)
        componentsArray.append(("name", NSLocalizedString("Name", comment: "Name"), [nameField], nil))
        
        var sexArray = [ParamsAbstract]()
        for i in iterateEnum(Profile.Sex.self) {
            let paramsSelectField = ParamsSelectField.initFromNib()
            paramsSelectField.setView(placeholder: i.localValue, parrent: self, name: "sex", rawValue: i.rawValue)
            sexArray.append(paramsSelectField)
        }
        componentsArray.append(("sex", NSLocalizedString("Sex", comment: "Sex"), sexArray, nil))
        
        let birthdayField = ParamsDatePicker.initFromNib()
        birthdayField.setView(placeholder: NSLocalizedString("Birthday", comment: "Birthday"), parrent: self, name: "birthday", rawValue: nil)
        componentsArray.append(("birthday", NSLocalizedString("Birthday", comment: "Birthday"), [birthdayField], nil))
        
        let countryField = self.storyboard?.instantiateViewController(withIdentifier: "SearchTableViewController") as! SearchTableViewController
        countryField.request = searchCountries
        countryField.name = "country"
        componentsArray.append(("country", NSLocalizedString("Country", comment: "Country"), nil, countryField))
        
        let cityField = self.storyboard?.instantiateViewController(withIdentifier: "SearchTableViewController") as! SearchTableViewController
        cityField.request = searchCities
        cityField.name = "city"
        componentsArray.append(("city", NSLocalizedString("City", comment: "City"), nil, cityField))
        
        let aboutField = ParamsTextField.initFromNib()
        aboutField.setView(placeholder: NSLocalizedString("Write about yourself", comment: "Write about yourself"), parrent: self, name: "about", rawValue: nil)
        componentsArray.append(("about", NSLocalizedString("About me", comment: "About me"), [aboutField], nil))
        
        var alcoholArray = [ParamsAbstract]()
        for i in iterateEnum(Profile.Alcohol.self) {
            let paramsSelectField = ParamsSelectField.initFromNib()
            paramsSelectField.setView(placeholder: i.localValue, parrent: self, name: "alcohol", rawValue: i.rawValue)
            alcoholArray.append(paramsSelectField)
        }
        componentsArray.append(("alcohol", NSLocalizedString("Alcohol", comment: "Alcohol"), alcoholArray, nil))
        
        var smokingArray = [ParamsAbstract]()
        for i in iterateEnum(Profile.Smoking.self) {
            let paramsSelectField = ParamsSelectField.initFromNib()
            paramsSelectField.setView(placeholder: i.localValue, parrent: self, name: "smoking", rawValue: i.rawValue)
            smokingArray.append(paramsSelectField)
        }
        componentsArray.append(("smoking", NSLocalizedString("Smoking", comment: "Smoking"), smokingArray, nil))
        
        var familyArray = [ParamsAbstract]()
        for i in iterateEnum(Profile.Family.self) {
            let paramsSelectField = ParamsSelectField.initFromNib()
            paramsSelectField.setView(placeholder: i.localValue, parrent: self, name: "familyStatus", rawValue: i.rawValue)
            familyArray.append(paramsSelectField)
        }
        componentsArray.append(("familyStatus", NSLocalizedString("Family status", comment: "Family status"), familyArray, nil))
        
        var childsArray = [ParamsAbstract]()
        for i in iterateEnum(Profile.Childs.self) {
            let paramsSelectField = ParamsSelectField.initFromNib()
            paramsSelectField.setView(placeholder: i.localValue, parrent: self, name: "childs", rawValue: i.rawValue)
            childsArray.append(paramsSelectField)
        }
        componentsArray.append(("childs", NSLocalizedString("Have children", comment: "Have children"), childsArray, nil))
        
        var orientationArray = [ParamsAbstract]()
        for i in iterateEnum(Profile.Orientation.self) {
            let paramsSelectField = ParamsSelectField.initFromNib()
            paramsSelectField.setView(placeholder: i.localValue, parrent: self, name: NSLocalizedString("orientation", comment: "Sexual orientation"), rawValue: i.rawValue)
            orientationArray.append(paramsSelectField)
        }
        componentsArray.append(("orientation", NSLocalizedString("Sexual orientation", comment: "Sexual orientation"), orientationArray, nil))
        
        dropStackView.addComponents(componentsArray)
    }
}


extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCell", for: indexPath) as! ProfileCollectionViewCell
        cell.profileImage.image = photoArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
    
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var image: UIImage?
        
        if let editedImage = info ["UIImagePickerControllerEditedImage"] {
            image = editedImage as? UIImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] {
            image = originalImage as? UIImage
        }
        if let image = image {
            photoArray.append(image)
        }
        
        collectionView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
}


