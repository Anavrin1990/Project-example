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
    var countryDefault = UserDefaults.standard.value(forKey: "countryDefault") as? String ?? "All"
    var sexDefault = UserDefaults.standard.value(forKey: "sexDefault") as? String ?? "createdate"
    
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
                self.countryDefault = UserDefaults.standard.value(forKey: "countryDefault") as? String ?? "All"
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
        
        let items = [(NSLocalizedString("Country", comment: "Country"), NSLocalizedString(countryDefault, comment: countryDefault)), (NSLocalizedString("Sex", comment: "Sex"), NSLocalizedString(sexDefault.toSex()!, comment: sexDefault.toSex()!))]
        
        menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: items[0].1, items: items)
        
        menuView.didSelectItemAtIndexHandler = {(tableView, indexPath: Int) -> Void in
            let tableView = tableView as! BTTableView
            
            let searchController = self.storyboard?.instantiateViewController(withIdentifier: "SearchTableViewController") as! SearchTableViewController
            searchController.withTopConstraint = false
            
            if indexPath == 0 {
                emptyCellCountryName = NSLocalizedString("All", comment: "All")
                searchController.request = searchCountries(_:)
            } else {
                searchController.contentArray = [(NSLocalizedString("Sex", comment: "Sex"), [("createdate", NSLocalizedString("All", comment: "All")), ("male_createdate", NSLocalizedString("Male", comment: "Male")), ("female_createdate", NSLocalizedString("Female", comment: "Female"))])]
            }
            
            searchController.resultComplition = { (rawValue: String, localValue: String) in
                tableView.items[indexPath] = (items[indexPath].0, localValue)
                if indexPath == 0 {
                     self.menuView.setMenuTitle(localValue)
                    UserDefaults.standard.set(localValue, forKey: "countryDefault")
                    self.countryDefault = localValue
                } else {
                    UserDefaults.standard.set(rawValue, forKey: "sexDefault")
                    self.sexDefault = rawValue
                }
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
                            self.menuView.setMenuTitle(self.countryDefault)
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
    
    func firstRequest () {
        Request.requestSingleByChildLastIndex(reference: Request.ref.child("Travels").child("All").child(countryDefault), child: sexDefault) { (snapshot, error) in
            guard error == nil else {print (error as Any); return}
            
            Parsing.travelsParseFirst(snapshot, complition: { (travelsArray) in
                
                if self.sexDefault == "male_createdate" {
                    self.lastPosition = travelsArray.first?.male_createdate
                } else if self.sexDefault == "female_createdate"{
                    self.lastPosition = travelsArray.first?.female_createdate
                } else {
                    self.lastPosition = travelsArray.first?.createDate
                }
                
                Request.requestSingleFirstByChild(reference: Request.ref.child("Travels").child("All").child(self.countryDefault), child: self.sexDefault, limit: reqLimit) { (snapshot, error) in
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
            
            Request.requestSingleNextByChild(reference: Request.ref.child("Travels").child("All").child(countryDefault), child: sexDefault, ending: endIndex - 1, limit: reqLimit, complition: { (snapshot, error) in
                
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
