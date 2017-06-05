//
//  ProfileViewController.swift
//  TravelTogether
//
//  Created by Dmitry on 03.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit

var person = Person()
var profileDict = [Int: String]()

class ProfileViewController: UIViewController, ParamsViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    var photoArray = [#imageLiteral(resourceName: "Аня"), #imageLiteral(resourceName: "Настя"), #imageLiteral(resourceName: "Саша"), #imageLiteral(resourceName: "Таня")]
    static var paramsArray = [ParamsDropStack]()
    static var headersArray = [ParamsView]()
    
    static var selectedIndex: Int?
    let keyArray = [NSLocalizedString("Имя", comment: "Имя"), NSLocalizedString("Пол", comment: "Пол"), NSLocalizedString("Дата рождения", comment: "Дата рождения"), NSLocalizedString("Местоположение", comment: "Местоположение"), NSLocalizedString("О себе", comment: "О себе"), NSLocalizedString("Алкоголь", comment: "Алкоголь"), NSLocalizedString("Курение", comment: "Курение"), NSLocalizedString("Отношения", comment: "Отношения"), NSLocalizedString("Дети", comment: "Дети"), NSLocalizedString("Ориентация", comment: "Ориентация"), NSLocalizedString("Вид отдыха", comment: "Вид отдыха"), NSLocalizedString("Проживание", comment: "Проживание"), NSLocalizedString("Интересы", comment: "Интересы") ]
    
    @IBOutlet weak var paramsStackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delaysContentTouches = false
        registerForKeyboardNotifications()
        ParamsView.delegate = self
        for key in keyArray.enumerated() {
            let paramsDropStack = Bundle.main.loadNibNamed("ParamsDropStack", owner: self, options: nil)?.first as! ParamsDropStack
            let headerView = Bundle.main.loadNibNamed("ParamsView", owner: self, options: nil)?.first as! ParamsView
            headerView.tag = key.offset
            headerView.paramKey.text = key.element
            headerView.paramValue.text = NSLocalizedString("Не заполнено", comment: "Не заполнено")
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
    
    func onParamsViewClick(index: Int) {
        self.view.endEditing(true)
        
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
            let text = profileDict[$0.offset]
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
        person.name = profileDict[0]
        person.sex = profileDict[1]
        person.birthday = profileDict[2]
        person.country = profileDict[3]
        person.about = profileDict[4]
        person.alcohol = profileDict[5]
        person.smoking = profileDict[6]
        person.familyStatus = profileDict[7]
        person.childs = profileDict[8]
        person.orientation = profileDict[9]
        person.travelKind = profileDict[10]
        person.staing = profileDict[11]
        person.hobbies = [profileDict[12]]
        
        let mirror = Mirror(reflecting: person)
        for i in mirror.children {
            print (i.label)
            print (i.value)
            print ("--------")
        }
        
    }
    
    
    func addDropList(_ index: Int) {
        switch index {
        case 0:
            let paramsTextField = ParamsTextField.initFromNib()
            paramsTextField.setView(placeholder: NSLocalizedString("Введите ваше имя", comment: "Введите ваше имя"), parrent: self, tag: index)
            ProfileViewController.paramsArray[index].stackView.addArrangedSubview(paramsTextField)
        case 1:
            let sexArray = [NSLocalizedString("Мужской", comment: "Мужской"), NSLocalizedString("Женский", comment: "Женский")]
            for i in sexArray {
                let paramsSelectField = ParamsSelectField.initFromNib()
                paramsSelectField.setView(placeholder: i, parrent: self, tag: index)
                ProfileViewController.paramsArray[index].stackView.addArrangedSubview(paramsSelectField)
            }
        case 2:
            let paramsDataPicker = ParamsDatePicker.initFromNib()
            paramsDataPicker.setView(placeholder: NSLocalizedString("Дата рождения", comment: "Дата рождения"), parrent: self, tag: index)
            ProfileViewController.paramsArray[index].stackView.addArrangedSubview(paramsDataPicker)
        case 3:
            break
        case 4:
            break
        case 5:
            let alcoholArray = [NSLocalizedString("Приемлю", comment: "Приемлю"), NSLocalizedString("Не приемлю", comment: "Не приемлю")]
            for i in alcoholArray {
                let paramsSelectField = ParamsSelectField.initFromNib()
                paramsSelectField.setView(placeholder: i, parrent: self, tag: index)
                ProfileViewController.paramsArray[index].stackView.addArrangedSubview(paramsSelectField)
            }
        case 6:
            let smokingArray = [NSLocalizedString("Приемлю", comment: "Приемлю"), NSLocalizedString("Не приемлю", comment: "Не приемлю")]
            for i in smokingArray {
                let paramsSelectField = ParamsSelectField.initFromNib()
                paramsSelectField.setView(placeholder: i, parrent: self, tag: index)
                ProfileViewController.paramsArray[index].stackView.addArrangedSubview(paramsSelectField)
            }
        case 7:
            let familyArray = [NSLocalizedString("Холост", comment: "Холост"), NSLocalizedString("В браке", comment: "В браке")]
            for i in familyArray {
                let paramsSelectField = ParamsSelectField.initFromNib()
                paramsSelectField.setView(placeholder: i, parrent: self, tag: index)
                ProfileViewController.paramsArray[index].stackView.addArrangedSubview(paramsSelectField)
            }
        case 8:
            let childsArray = [NSLocalizedString("Есть", comment: "Есть"), NSLocalizedString("Нет", comment: "Нет")]
            for i in childsArray {
                let paramsSelectField = ParamsSelectField.initFromNib()
                paramsSelectField.setView(placeholder: i, parrent: self, tag: index)
                ProfileViewController.paramsArray[index].stackView.addArrangedSubview(paramsSelectField)
            }
        case 9:
            let orientationArray = [NSLocalizedString("Гетеро", comment: "Гетеро"), NSLocalizedString("Гомо", comment: "Гомо"), NSLocalizedString("Би", comment: "Би")]
            for i in orientationArray {
                let paramsSelectField = ParamsSelectField.initFromNib()
                paramsSelectField.setView(placeholder: i, parrent: self, tag: index)
                ProfileViewController.paramsArray[index].stackView.addArrangedSubview(paramsSelectField)
            }
        case 10:
            let travelKindArray = [NSLocalizedString("Активный", comment: "Активный"), NSLocalizedString("Пляжный", comment: "Пляжный")]
            for i in travelKindArray {
                let paramsSelectField = ParamsSelectField.initFromNib()
                paramsSelectField.setView(placeholder: i, parrent: self, tag: index)
                ProfileViewController.paramsArray[index].stackView.addArrangedSubview(paramsSelectField)
            }
        case 11:
            let staingArray = [NSLocalizedString("В отеле", comment: "В отеле"), NSLocalizedString("Съем жилья", comment: "Съем жилья")]
            for i in staingArray {
                let paramsSelectField = ParamsSelectField.initFromNib()
                paramsSelectField.setView(placeholder: i, parrent: self, tag: index)
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
