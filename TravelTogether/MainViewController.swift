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

let userDefault = UserDefaults()
var imageCache = NSCache<AnyObject, AnyObject>()
let reqLimit: UInt = 15

var categoriesArray = [String]()
var difficultyArray = [Int]()

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITabBarControllerDelegate {
    
    
    var personArray = [Person]()
    var endIndex: Int?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.collectionView.alwaysBounceVertical = true
        
        refreshControl.backgroundColor = .white
        refreshControl.addTarget(self, action: #selector(firstRequest), for: .valueChanged)
        collectionView?.addSubview(refreshControl)
        
        //spinner.startAnimating()
        
        spinnerSettings()
        firstRequest()
    }
    
    func spinnerSettings() {
        
        collectionView?.addSubview(spinner)
        NSLayoutConstraint(item: spinner, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: spinner, attribute: .centerY, relatedBy: .equal, toItem: collectionView, attribute: .centerY, multiplier: 0.85, constant: 0).isActive = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.personArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCell", for: indexPath) as! MainCollectionViewCell
        
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
    
    
    
    
    func firstRequest () {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    
    
    
}
