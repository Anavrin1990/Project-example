//
//  ProfileViewController.swift
//  TravelTogether
//
//  Created by Dmitry on 03.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProfileViewController: UIViewController, ParamsViewDelegate, SearchTableViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    let imagePicker = UIImagePickerController()
    
    var photoArray = [UIImage]()
    static var paramsArray = [ParamsDropStack]()
    static var headersArray = [ParamsView]()
    
    static var selectedIndex: Int?
    
    var countryId = ""
    
    let keyArray = [NSLocalizedString("Name", comment: "Name"), NSLocalizedString("Sex", comment: "Sex"), NSLocalizedString("Birthdate", comment: "Birthdate"), NSLocalizedString("Country", comment: "Country"), NSLocalizedString("City", comment: "City"), NSLocalizedString("About me", comment: "About me"), NSLocalizedString("Alcohol", comment: "Alcohol"), NSLocalizedString("Smoking", comment: "Smoking"), NSLocalizedString("Marital status", comment: "Marital status"), NSLocalizedString("Have children", comment: "Have children"), NSLocalizedString("Sexual orientation", comment: "Sexual orientation"), NSLocalizedString("Type of travel", comment: "Type of travel"), NSLocalizedString("Staying", comment: "Staying")]
    
    @IBOutlet weak var paramsStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delaysContentTouches = false
        registerForKeyboardNotifications()
        ParamsView.delegate = self
        SearchTableViewController.delegate = self
        
        for key in keyArray.enumerated() {
            let paramsDropStack = Bundle.main.loadNibNamed("ParamsDropStack", owner: self, options: nil)?.first as! ParamsDropStack
            let headerView = Bundle.main.loadNibNamed("ParamsView", owner: self, options: nil)?.first as! ParamsView
            headerView.tag = key.offset
            headerView.paramKey.text = key.element
            headerView.paramValue.text = NSLocalizedString("Not filled", comment: "Not filled")
            paramsDropStack.stackView.addArrangedSubview(headerView)
            ProfileViewController.headersArray.append(headerView)
            ProfileViewController.paramsArray.append(paramsDropStack)
            addDropList(key.offset)
            paramsStackView.addArrangedSubview(paramsDropStack)
        }
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
        scrollView.contentOffset = CGPoint(x: 0, y: kbFrameSize.height / 3)
    }
    
    func kbWillHide() {
        scrollView.contentOffset = CGPoint.zero
    }
    
    func searchCountries (_ complition: @escaping (_ content: [(String, [(String, String)])]) -> ()) {
        Request.getJSON(url: "https://api.vk.com/api.php?oauth=1&method=database.getCountries&v=5.65&need_all=1&lang=en&count=1000") { (json) in
            var countriesArray = [(String, String)]()
            let countries = json["response"]["items"].arrayValue
            for c in countries {
                let country = (c["id"].stringValue, c["title"].stringValue)
                countriesArray.append(country)
            }
            let result = (NSLocalizedString("Countries", comment: "Countries"), countriesArray)
            complition([result])
        }
    }
    
    func searchCities (_ complition: @escaping (_ content: [(String, [(String, String)])]) -> ()) {
        Request.getJSON(url: "https://api.vk.com/api.php?oauth=1&method=database.getCities&v=5.5&country_id=\(countryId)&lang=en&count=1000") { (json) in
            var citiesArray = [(String, String)]()
            let cities = json["response"]["items"].arrayValue
            for c in cities {
                let city = (c["id"].stringValue, c["title"].stringValue)
                citiesArray.append(city)
            }
            let result = (NSLocalizedString("Nearest city", comment: "Nearest city"), citiesArray)
            complition([result])
        }
    }
    
    func onParamsViewClick(index: Int) {
        self.view.endEditing(true)
        
        let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchTableViewController") as! SearchTableViewController
        searchVC.index = index
        
        ProfileViewController.paramsArray.forEach {
            $0.stackView.subviews.forEach {
                if let view = $0 as? ParamsViewsProtocol {
                    if index != ProfileViewController.selectedIndex {
                        view.hide()
                    }
                    view.getValue()
                }
            }
        }
        
        ProfileViewController.headersArray.enumerated().forEach {
            let text = Person.profileDict[$0.offset]?.1
            if text != "" && text != nil {
                $0.element.paramValue.text = text
            }
        }
        
        ProfileViewController.selectedIndex = index
        
        ProfileViewController.paramsArray[index].stackView.subviews.forEach {
            if let view = $0 as? ParamsViewsProtocol {
                view.showHide()
            }
        }
        
        switch index {
        case 3:
            searchVC.request = searchCountries(_:)
            self.navigationController?.pushViewController(searchVC, animated: true)
        case 4:
            searchVC.request = searchCities(_:)
            self.navigationController?.pushViewController(searchVC, animated: true)
        default:
            break
        }
    }
    
    func getSearchResult(result: (String, String), index: Int?) {
        if index == 3 {self.countryId = result.0}
        
        Person.profileDict[index!] = (result.1, result.1)
        
        ProfileViewController.headersArray.enumerated().forEach {
            let text = Person.profileDict[$0.offset]?.1
            if text != "" && text != nil {
                $0.element.paramValue.text = text
            }
        }
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func nextButton(_ sender: Any) {
        
        ProfileViewController.paramsArray.forEach {
            $0.stackView.subviews.forEach {
                if let view = $0 as? ParamsViewsProtocol {
                    view.hide()
                    view.getValue()
                }
            }
        }
        
        Person.instance.name = Person.profileDict[0]?.0
        Person.instance.sex = Person.profileDict[1]?.0
        Person.instance.birthdate = Person.profileDict[2]?.0
        Person.instance.country = Person.profileDict[3]?.0
        Person.instance.city = Person.profileDict[4]?.0
        Person.instance.about = Person.profileDict[5]?.0
        Person.instance.alcohol = Person.profileDict[6]?.0
        Person.instance.smoking = Person.profileDict[7]?.0
        Person.instance.familyStatus = Person.profileDict[8]?.0
        Person.instance.childs = Person.profileDict[9]?.0
        Person.instance.orientation = Person.profileDict[10]?.0
        Person.instance.travelKind = Person.profileDict[11]?.0
        Person.instance.staying = Person.profileDict[12]?.0
        
        var userProperties = [AnyHashable : Any]()
        
        let mirror = Mirror(reflecting: Person.instance)
        for i in mirror.children.enumerated() {
            if i.1.value as? String == nil || i.1.value as? String == "" {
                MessageBox.showMessage(parent: self, title: ProfileViewController.headersArray[i.0].paramKey.text!, message: NSLocalizedString("Not filled", comment: "Not filled"))
                return
            } else {
                userProperties[i.1.label!] = i.1.value
            }
        }
        if let uid = User.uid {
            Request.updateChildValue(reference: Request.ref.child("Users").child(uid), value: userProperties, complition: {})
            for (k, v) in userProperties {
                Request.updateChildValue(reference: Request.ref.child("Criteria").child(k as! String).child(uid), value: [k : v], complition: {})
            }
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func addDropList(_ index: Int) {
        switch index {
        case 0:
            let paramsTextField = ParamsTextField.initFromNib()
            paramsTextField.setView(placeholder: NSLocalizedString("Enter your name", comment: "Enter your name"), parrent: self, tag: index, rawValue: nil)
            ProfileViewController.paramsArray[index].stackView.addArrangedSubview(paramsTextField)
        case 1:
            let sexArray = [Profile.Sex.male, Profile.Sex.female]
            for i in sexArray {
                let paramsSelectField = ParamsSelectField.initFromNib()
                paramsSelectField.setView(placeholder: i.localValue, parrent: self, tag: index, rawValue: i.rawValue)
                ProfileViewController.paramsArray[index].stackView.addArrangedSubview(paramsSelectField)
            }
        case 2:
            let paramsDataPicker = ParamsDatePicker.initFromNib()
            paramsDataPicker.setView(placeholder: NSLocalizedString("Birthdate", comment: "Birthdate"), parrent: self, tag: index, rawValue: nil)
            ProfileViewController.paramsArray[index].stackView.addArrangedSubview(paramsDataPicker)
        case 5:
            let paramsTextField = ParamsTextField.initFromNib()
            paramsTextField.setView(placeholder: NSLocalizedString("Write about yourself", comment: "Write about yourself"), parrent: self, tag: index, rawValue: nil)
            ProfileViewController.paramsArray[index].stackView.addArrangedSubview(paramsTextField)
        case 6:
            let alcoholArray = [Profile.Alcohol.positive, Profile.Alcohol.negative]
            for i in alcoholArray {
                let paramsSelectField = ParamsSelectField.initFromNib()
                paramsSelectField.setView(placeholder: i.localValue, parrent: self, tag: index, rawValue: i.rawValue)
                ProfileViewController.paramsArray[index].stackView.addArrangedSubview(paramsSelectField)
            }
        case 7:
            let smokingArray = [Profile.Smoking.positive, Profile.Smoking.negative]
            for i in smokingArray {
                let paramsSelectField = ParamsSelectField.initFromNib()
                paramsSelectField.setView(placeholder: i.localValue, parrent: self, tag: index, rawValue: i.rawValue)
                ProfileViewController.paramsArray[index].stackView.addArrangedSubview(paramsSelectField)
            }
        case 8:
            let familyArray = [Profile.Family.single, Profile.Family.married]
            for i in familyArray {
                let paramsSelectField = ParamsSelectField.initFromNib()
                paramsSelectField.setView(placeholder: i.localValue, parrent: self, tag: index, rawValue: i.rawValue)
                ProfileViewController.paramsArray[index].stackView.addArrangedSubview(paramsSelectField)
            }
        case 9:
            let childsArray = [Profile.Childs.no, Profile.Childs.yes]
            for i in childsArray {
                let paramsSelectField = ParamsSelectField.initFromNib()
                paramsSelectField.setView(placeholder: i.localValue, parrent: self, tag: index, rawValue: i.rawValue)
                ProfileViewController.paramsArray[index].stackView.addArrangedSubview(paramsSelectField)
            }
        case 10:
            let orientationArray = [Profile.Orientation.hetero, Profile.Orientation.homo, Profile.Orientation.bi]
            for i in orientationArray {
                let paramsSelectField = ParamsSelectField.initFromNib()
                paramsSelectField.setView(placeholder: i.localValue, parrent: self, tag: index, rawValue: i.rawValue)
                ProfileViewController.paramsArray[index].stackView.addArrangedSubview(paramsSelectField)
            }
        case 11:
            let travelTypeArray = [Profile.TravelType.active, Profile.TravelType.beachRest]
            for i in travelTypeArray {
                let paramsSelectField = ParamsSelectField.initFromNib()
                paramsSelectField.setView(placeholder: i.localValue, parrent: self, tag: index, rawValue: i.rawValue)
                ProfileViewController.paramsArray[index].stackView.addArrangedSubview(paramsSelectField)
            }
        case 12:
            let stayingArray = [Profile.Staying.hotel, Profile.Staying.hostel, Profile.Staying.rent]
            for i in stayingArray {
                let paramsSelectField = ParamsSelectField.initFromNib()
                paramsSelectField.setView(placeholder: i.localValue, parrent: self, tag: index, rawValue: i.rawValue)
                ProfileViewController.paramsArray[index].stackView.addArrangedSubview(paramsSelectField)
            }
        default:
            break
        }
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


