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
    
    var travelsArray = [Travel]()
    var endIndex: Int?
    var lastPosition: Int?
    
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
        
        spinnerSettings()

        firstRequest()
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
                            let hasTravel = json["hasTravel"].boolValue
                            if !hasTravel {
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
        Request.requestSingleByChildLastIndex(reference: Request.ref.child("Travels").child("All"), child: "createdate") { (snapshot, error) in
            guard error == nil else {print (error as Any); return}
            
            Parsing.travelsParseFirst(snapshot, complition: { (travelsArray) in
                self.lastPosition = travelsArray.first?.createDate
                
                Request.requestSingleFirstByChild(reference: Request.ref.child("Travels").child("All"), child: "createdate", limit: reqLimit) { (snapshot, error) in
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
            
            Request.requestSingleNextByChild(reference: Request.ref.child("Travels").child("All"), child: "createdate", ending: endIndex - 1, limit: reqLimit, complition: { (snapshot, error) in
                
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
