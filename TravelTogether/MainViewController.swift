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
    let items = ["Most Popular", "Latest", "Trending", "Nearest", "Top Picks"]
    var travelsArray = [Travel]()
    var endIndex: Int?
    var lastPosition: Int?
    var countryDefault = "All"
    
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
            Request.getUserInfo{
                self.checkAuth()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green:180/255.0, blue:220/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        //        var q = 170628235713
        //        for _ in 0...20 {
        //            var value = [String : Int]()
        //            value["name"] = q
        //            value["createdate"] = q
        //            Request.updateChildValue(reference: Request.ref.child("Travels").child("All").childByAutoId(), value: value, complition: {})
        //            q += 10
        //        }
        
        self.collectionView.alwaysBounceVertical = true
        
        refreshControl.backgroundColor = .white
        refreshControl.addTarget(self, action: #selector(firstRequest), for: .valueChanged)
        collectionView?.addSubview(refreshControl)
        
        spinner.startAnimating()
        navigationDropdownMenu()
        spinnerSettings()
        firstRequest()
    }
    
    func navigationDropdownMenu() {
        menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: BTTitle.index(2), items: items)
        
        menuView.cellHeight = 50
        menuView.cellBackgroundColor = self.navigationController?.navigationBar.barTintColor
        menuView.cellSelectionColor = UIColor(red: 0.0/255.0, green:160.0/255.0, blue:195.0/255.0, alpha: 1.0)
        menuView.shouldKeepSelectedCellColor = true
        menuView.cellTextLabelColor = UIColor.white
        menuView.cellTextLabelFont = UIFont(name: "System-Regular", size: 17)
        menuView.cellTextLabelAlignment = .left // .Center // .Right // .Left
        menuView.arrowPadding = 15
        menuView.animationDuration = 0.5
        menuView.maskBackgroundColor = UIColor.black
        menuView.maskBackgroundOpacity = 0.3
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> Void in
            print("Did select item at index: \(indexPath)")
            
            let search = self.storyboard?.instantiateViewController(withIdentifier: "SearchTableViewController") as! SearchTableViewController
            search.withTopConstraint = false
            search.resultComplition = { (monthInt: String, monthString: String) in
                print (monthString)
                print (monthInt)
            }
            self.navigationController?.pushViewController(search, animated: true)
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
        Request.requestSingleByChildLastIndex(reference: Request.ref.child("Travels").child("All").child(countryDefault), child: "createdate") { (snapshot, error) in
            guard error == nil else {print (error as Any); return}
            
            Parsing.travelsParseFirst(snapshot, complition: { (travelsArray) in
                self.lastPosition = travelsArray.first?.createDate
                
                Request.requestSingleFirstByChild(reference: Request.ref.child("Travels").child("All").child(self.countryDefault), child: "createdate", limit: reqLimit) { (snapshot, error) in
                    guard error == nil else {print (error as Any); return}
                    
                    Parsing.travelsParseFirst(snapshot, complition: { (travelsArray) in
                        self.travelsArray = travelsArray
                        
                        self.travelsArray.sort(by: { (first, second) -> Bool in
                            guard let firstCreateDate = first.createDate, let secondCreateDate = second.createDate else {return false}
                            return firstCreateDate < secondCreateDate
                        })
                        self.travelsArray.reverse()
                        self.endIndex = self.travelsArray.last?.createDate
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
            
            Request.requestSingleNextByChild(reference: Request.ref.child("Travels").child("All").child(countryDefault), child: "createdate", ending: endIndex - 1, limit: reqLimit, complition: { (snapshot, error) in
                
                guard error == nil else {print (error as Any); return}
                
                Parsing.travelsParseSecond(snapshot, complition: { (preArray) in
                    for i in preArray {
                        self.travelsArray.append(i)
                    }
                })
                self.endIndex = self.travelsArray.last?.createDate
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            })
        }
        
    }
    
    
    
    
}
