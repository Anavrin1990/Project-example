//
//  MainViewController.swift
//  TravelTogether
//
//  Created by Dmitry on 31.05.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import SwiftyJSON

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITabBarControllerDelegate {
    
    static var needCheckAuth = true // включение проверки авторизации
    
    var menuView: BTNavigationDropdownMenu!
    
    var travelsArray = [Travel]()
    var endIndex: Int?
    var lastPosition: Int?
    
    var countryDefault = UserDefaults.standard.value(forKey: "countryDefault") as? String ?? "AllCountries"
    var cityDefault = UserDefaults.standard.value(forKey: "cityDefault") as? String ?? "AllCities"
    var sexDefault = UserDefaults.standard.value(forKey: "sexDefault") as? String ?? "createdate"
    var ageDefault = UserDefaults.standard.value(forKey: "ageDefault") as? String ?? "AllAges"
    var destinationDefault = UserDefaults.standard.value(forKey: "destinationDefault") as? String ?? "AllCountries"
    var monthDefault = UserDefaults.standard.value(forKey: "monthDefault") as? String ?? "AllMonths"
    
    let spinner: UIActivityIndicatorView = {
        let spin = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spin.translatesAutoresizingMaskIntoConstraints = false
        spin.color = UIColor.darkGray
        spin.hidesWhenStopped = true
        return spin
    }()
    
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate lazy var cellWidth: CGFloat = {
        let minimumInteritemSpacing = (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing
        return self.collectionView!.frame.width/2  - minimumInteritemSpacing/2
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if MainViewController.needCheckAuth {
            Request.getUserInfo {
                self.countryDefault = UserDefaults.standard.value(forKey: "countryDefault") as? String ?? "AllCountries"
                self.checkAuth()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.isTranslucent = false
        
        //                var q = 179976175556
        //                for i in 0...20 {
        //                    var value = [String : Any]()
        //                    value["name"] = "male" + String(i)
        //                    value["createdate"] = q
        //                    value["male_createdate"] = q
        //                    Request.updateChildValue(reference: Request.ref.child("Travels").child("All").child("All").childByAutoId(), value: value, complition: {})
        //                    q += 10
        //                }
        
        self.collectionView.alwaysBounceVertical = true
        
        refreshControl.backgroundColor = .white
        refreshControl.addTarget(self, action: #selector(firstRequest), for: .valueChanged)
        collectionView?.addSubview(refreshControl)
        
        spinner.startAnimating()
        navigationDropdownMenu()
        spinnerSettings()
    }
    
    func navigationDropdownMenu() {
        
        let items = [(NSLocalizedString("Country", comment: "Country"), countryDefault.toCountry()),
                     (NSLocalizedString("City", comment: "City"), cityDefault.toCity()),
                     (NSLocalizedString("Sex", comment: "Sex"), sexDefault.toSex()),
                     (NSLocalizedString("Age", comment: "Age"), ageDefault.toAgeRange()),
                     (NSLocalizedString("Destination", comment: "Destination"), destinationDefault.toCountry()),
                     (NSLocalizedString("Month", comment: "Month"), monthDefault.toMonth()),
                     (NSLocalizedString("Reset", comment: "Reset"), "")]
        
        menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: items[0].1, items: items)
        
        menuView.didSelectItemAtIndexHandler = {(tableView, indexPath: Int) -> Void in
            let tableView = tableView as! BTTableView
            
            let searchController = self.storyboard?.instantiateViewController(withIdentifier: "SearchTableViewController") as! SearchTableViewController
            searchController.withTopConstraint = false
            
            if indexPath == 0 {
                emptySearchName = ("AllCountries", NSLocalizedString("All countries", comment: "All countries"))
                searchController.request = searchCountries(_:)
                
            } else if indexPath == 1 {
                emptySearchName = ("AllCities", NSLocalizedString("All cities", comment: "All cities"))
                searchController.request = searchCities(_:)
                
            } else if indexPath == 2 {
                searchController.contentArray = [(NSLocalizedString("Sex", comment: "Sex"), [("createdate", NSLocalizedString("All", comment: "All")), ("male_createdate", NSLocalizedString("Male", comment: "Male")), ("female_createdate", NSLocalizedString("Female", comment: "Female"))])]
                
            } else if indexPath == 3 {
                var rangeArray = [(rawValue: String, localValue: String)]()
                for range in iterateEnum(AgeRange.self) {
                    rangeArray.append((rawValue: range.rawValue, localValue: range.localValue))
                }
                searchController.contentArray = [(NSLocalizedString("Age range", comment: "Age range"), rangeArray)]
            } else if indexPath == 4 {
                emptySearchName = ("AllCountries", NSLocalizedString("All countries", comment: "All countries"))
                searchController.request = searchCountries(_:)
                
            } else if indexPath == 5 {
                var monthArray = [(rawValue: "AllMonths", localValue: "All months")]
                for month in MonthPickerView.months.enumerated() {
                    monthArray.append((rawValue: String(month.offset + 1), localValue: month.element))
                }
                searchController.contentArray = [(NSLocalizedString("Months", comment: "Months"), monthArray)]
                
            } else if indexPath == 6 {
                self.countryDefault = User.person!.country!
                self.cityDefault = User.person!.city!
                self.sexDefault = "createdate"
                self.ageDefault = "AllAges"
                self.destinationDefault = "AllCountries"
                self.monthDefault = "AllMonths"
                
                self.menuView.setMenuTitle(User.person!.country!)
                
                for item in items.enumerated() {
                    tableView.items[item.offset] = (item.element.0, item.element.1)
                }
                
                UserDefaults.standard.set(User.countryId, forKey: "countryId")
                UserDefaults.standard.set(User.person!.country!, forKey: "countryDefault")
                UserDefaults.standard.set(User.person!.city!, forKey: "cityDefault")
                UserDefaults.standard.set("createdate", forKey: "sexDefault")
                UserDefaults.standard.set("AllAges", forKey: "ageDefault")
                UserDefaults.standard.set("AllCountries", forKey: "destinationDefault")
                UserDefaults.standard.set("AllMonths", forKey: "monthDefault")
                UserDefaults.standard.synchronize()
                self.spinner.startAnimating()
                self.firstRequest()
                return
            }
            
            searchController.resultComplition = { (rawValue: String, localValue: String) in
                tableView.items[indexPath] = (items[indexPath].0, localValue)
                
                if indexPath == 0 {
                    countryId = rawValue
                    self.menuView.setMenuTitle(localValue)
                    let value = rawValue == "AllCountries" ? rawValue : localValue
                    UserDefaults.standard.set(value, forKey: "countryDefault")
                    UserDefaults.standard.set(rawValue, forKey: "countryId")
                    self.countryDefault = value
                    
                    tableView.items[1] = (items[indexPath].1, "AllCities")
                    UserDefaults.standard.set("AllCities", forKey: "cityDefault")
                    self.cityDefault = "AllCities"
                    
                } else if indexPath == 1 {
                    let value = rawValue == "AllCities" ? rawValue : localValue
                    UserDefaults.standard.set(value, forKey: "cityDefault")
                    self.cityDefault = value
                    
                } else if indexPath == 2 {
                    UserDefaults.standard.set(rawValue, forKey: "sexDefault")
                    self.sexDefault = rawValue
                    
                } else if indexPath == 3 {
                    UserDefaults.standard.set(rawValue, forKey: "ageDefault")
                    self.ageDefault = rawValue
                    
                } else if indexPath == 4 {
                    let value = rawValue == "AllCountries" ? rawValue : localValue
                    UserDefaults.standard.set(value, forKey: "destinationDefault")
                    self.destinationDefault = value
                    
                } else if indexPath == 5 {
                    UserDefaults.standard.set(rawValue, forKey: "monthDefault")
                    self.monthDefault = rawValue
                }
                
                UserDefaults.standard.synchronize()
                self.spinner.startAnimating()
                self.firstRequest()
            }
            self.navigationController?.pushViewController(searchController, animated: true)
        }
        self.navigationItem.titleView = menuView
    }
    
    func spinnerSettings() {
        collectionView?.addSubview(spinner)
        NSLayoutConstraint(item: spinner, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: spinner, attribute: .centerY, relatedBy: .equal, toItem: collectionView, attribute: .centerY, multiplier: 0.85, constant: 0).isActive = true
    }
    
    @IBAction func logout(_ sender: Any) {
        MessageBox.showDialog(parent: self, title: NSLocalizedString("Sign out", comment: "Sign out"), message: NSLocalizedString("Do you want to sign out?", comment: "Do you want to sign out?")) {
            Request.logOut {
                let registrationVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterNavigationController")
                self.present(registrationVC!, animated: true, completion: nil)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.travelsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCell", for: indexPath) as! MainCollectionViewCell
        cell.nameAgeLabel.text = "\(travelsArray[indexPath.row].name ?? ""), \(travelsArray[indexPath.row].birthday?.getAge() ?? "")"
        cell.destinationLabel.text = "\(travelsArray[indexPath.row].destination ?? ""). \(travelsArray[indexPath.row].month?.getMonth() ?? "")"
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.width / 2
        cell.profileImage.layer.masksToBounds = true
        cell.profileImage.getImage(url: travelsArray[indexPath.row].icon)
        return cell
    }
    
    // Размер ячеек
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth/1.02 , height: cellWidth*1.3 )
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPaths = collectionView?.indexPathsForSelectedItems {
                let indexPath = indexPaths[0] as NSIndexPath
                //                let dvc = segue.destination as! DetailViewController
                //                dvc.model = self.modelsArray[indexPath.row]
                //                dvc.arrayPosition = indexPath.row
            }
        }
    }
    
    func checkAuth() {
        if User.uid == nil {
            Request.logOut{}
            let registrationVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterNavigationController")
            present(registrationVC!, animated: true, completion: nil)
            return
        }
        if User.email == nil {
            Request.logOut{}
            let registrationVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterNavigationController")
            present(registrationVC!, animated: true, completion: nil)
            return
        }
        Request.requestSingleFirstByKey(reference: Request.ref.child("Users").child(User.uid!), limit: nil, complition: { (snapshot, error) in
            guard error == nil else {return}
            if let snap = snapshot?.value as? NSDictionary {
                let json = JSON(snap)
                let alcohol = json["alcohol"].stringValue
                if alcohol == "" {
                    let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileNavigationController")
                    DispatchQueue.main.async {
                        self.present(profileVC!, animated: true)
                    }
                    return
                } else {
                    Request.requestSingleFirstByKey(reference: Request.ref.child("Users").child(User.uid!), limit: nil, complition: { (snapshot, error) in
                        guard error == nil else {return}
                        if let snap = snapshot?.value as? NSDictionary {
                            let json = JSON(snap)
                            let travelsCount = json["travelsCount"].intValue
                            if travelsCount == 0 {
                                let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "TravelNavigationController")
                                DispatchQueue.main.async {
                                    self.present(profileVC!, animated: true)
                                }
                                return
                            }
                            MainViewController.needCheckAuth = false
                            self.menuView.setMenuTitle(self.countryDefault.toCountry())
                            self.firstRequest()
                        }
                    })
                }
            } else {
                Request.logOut{}
                let registrationVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterNavigationController")
                self.present(registrationVC!, animated: true, completion: nil)
            }
        })
    }
    
    func getReference() -> FIRDatabaseReference {
        let cityDefault = countryDefault == "AllCountries" ? "AllCities" : self.cityDefault
        
        var reference = Request.ref.child("Travels").child("AllTravels").child(countryDefault).child(cityDefault).child(ageDefault)
        
        if destinationDefault != "AllCountries" {
            reference = Request.ref.child("Travels").child("Destinations").child(countryDefault).child(cityDefault).child(destinationDefault).child(ageDefault)
            
        } else if monthDefault != "AllMonths" {
            reference = Request.ref.child("Travels").child("Months").child(countryDefault).child(cityDefault).child(monthDefault).child(ageDefault)
            
        } else if destinationDefault != "AllCountries" && monthDefault != "AllMonths" {
            reference = Request.ref.child("Travels").child("Match").child(countryDefault).child(cityDefault).child(destinationDefault).child(monthDefault).child(ageDefault)
        }
        return reference
    }
    
    func firstRequest () {
        
        Request.requestSingleByChildLastIndex(reference: getReference(), child: sexDefault) { (snapshot, error) in
            guard error == nil else {print (error as Any); return}
            
            Parsing.travelsParseFirst(snapshot, complition: { (travelsArray) in
                
                if self.sexDefault == "male_createdate" {
                    self.lastPosition = travelsArray.first?.male_createdate
                } else if self.sexDefault == "female_createdate"{
                    self.lastPosition = travelsArray.first?.female_createdate
                } else {
                    self.lastPosition = travelsArray.first?.createDate
                }
                
                Request.requestSingleFirstByChild(reference: self.getReference(), child: self.sexDefault, limit: reqLimit) { (snapshot, error) in
                    guard error == nil else {print (error as Any); return}
                    
                    Parsing.travelsParseFirst(snapshot, complition: { (travelsArray) in
                        self.travelsArray = travelsArray
                        
                        self.travelsArray.sort(by: { (first, second) -> Bool in
                            
                            if self.sexDefault == "male_createdate" {
                                guard let firstCreateDate = first.male_createdate, let secondCreateDate = second.male_createdate else {
                                    return false
                                }
                                return firstCreateDate < secondCreateDate
                            } else if self.sexDefault == "female_createdate"{
                                guard let firstCreateDate = first.female_createdate, let secondCreateDate = second.female_createdate else {
                                    return false
                                }
                                return firstCreateDate < secondCreateDate
                            } else {
                                return first.createDate! < second.createDate!
                            }
                        })
                        
                        self.travelsArray.reverse()
                        
                        if self.sexDefault == "male_createdate" {
                            self.endIndex = self.travelsArray.last?.male_createdate
                        } else if self.sexDefault == "female_createdate"{
                            self.endIndex = self.travelsArray.last?.female_createdate
                        } else {
                            self.endIndex = self.travelsArray.last?.createDate
                        }
                        
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                            self.spinner.stopAnimating()
                            self.refreshControl.endRefreshing()
                        }
                    })
                }
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.row == (travelsArray.count - 2) {
            
            guard let endIndex = self.endIndex else {return}
            guard let lastPosition = self.lastPosition else {return}
            guard endIndex > lastPosition else {return}
            
            Request.requestSingleNextByChild(reference: getReference(), child: sexDefault, ending: endIndex - 1, limit: reqLimit, complition: { (snapshot, error) in
                
                guard error == nil else {print (error as Any); return}
                
                Parsing.travelsParseSecond(snapshot, complition: { (preArray) in
                    var resultArray = preArray.sorted(by: { (first, second) -> Bool in
                        
                        if self.sexDefault == "male_createdate" {
                            guard let firstCreateDate = first.male_createdate, let secondCreateDate = second.male_createdate else {
                                return false
                            }
                            return firstCreateDate < secondCreateDate
                        } else if self.sexDefault == "female_createdate" {
                            guard let firstCreateDate = first.female_createdate, let secondCreateDate = second.female_createdate else {
                                return false
                            }
                            return firstCreateDate < secondCreateDate
                        } else {
                            return first.createDate! < second.createDate!
                        }
                    })
                    
                    resultArray.reverse()
                    for i in resultArray {
                        if self.sexDefault == "male_createdate", i.male_createdate == 0 {
                            continue
                        } else if self.sexDefault == "female_createdate", i.female_createdate == 0 {
                            continue
                        }
                        self.travelsArray.append(i)
                    }
                })
                
                if self.sexDefault == "male_createdate" {
                    self.endIndex = self.travelsArray.last?.male_createdate
                } else if self.sexDefault == "female_createdate"{
                    self.endIndex = self.travelsArray.last?.female_createdate
                } else {
                    self.endIndex = self.travelsArray.last?.createDate
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            })
        }
        
    }
    
    
    
    
}
