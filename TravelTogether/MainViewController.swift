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

    var travelsArray = [Travel]() {
        didSet {
            endIndex = self.travelsArray.last?.createDate
        }
    }
    var endIndex: Int?
    var lastPosition: Int?

    var countryDefault = ""
    var cityDefault = ""
    var sexDefault = UserDefaults.standard.value(forKey: "sexDefault") as? String ?? "AllSex"
    var ageDefault = UserDefaults.standard.value(forKey: "ageDefault") as? String ?? "AllAges"
    var destinationDefault = UserDefaults.standard.value(forKey: "destinationDefault") as? String ?? "AllCountries"
    var monthDefault = UserDefaults.standard.value(forKey: "monthDefault") as? String ?? "AllMonths"

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
                self.countryDefault = UserDefaults.standard.value(forKey: "countryDefault") as? String ?? User.person?.country ?? "AllCountries"
                self.cityDefault = UserDefaults.standard.value(forKey: "cityDefault") as? String ?? User.person?.city ?? "AllCities"
                countryId = UserDefaults.standard.value(forKey: "countryId") as? String ?? User.countryId ?? ""
                self.checkAuth()
                Request.updateStatus(.online)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.isTranslucent = false

        self.collectionView.alwaysBounceVertical = true

        refreshControl.backgroundColor = .white
        refreshControl.addTarget(self, action: #selector(firstRequest), for: .valueChanged)
        collectionView?.addSubview(refreshControl)

        self.collectionView.addSpinner()
        spinner.startAnimating()


    }

    // MARK: Navigation drop menu
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

            // Set cells
            if indexPath == 0 {
                emptySearchName = ("AllCountries", NSLocalizedString("All countries", comment: "All countries"))
                searchController.request = searchCountries(_:)

            } else if indexPath == 1 {
                emptySearchName = ("AllCities", NSLocalizedString("All cities", comment: "All cities"))
                searchController.request = searchCities(_:)

            } else if indexPath == 2 {
                searchController.contentArray = [(NSLocalizedString("Sex", comment: "Sex"), [("AllSex", NSLocalizedString("All", comment: "All")), ("Male", NSLocalizedString("Male", comment: "Male")), ("Female", NSLocalizedString("Female", comment: "Female"))])]

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
                self.sexDefault = "AllSex"
                self.ageDefault = "AllAges"
                self.destinationDefault = "AllCountries"
                self.monthDefault = "AllMonths"
                countryId = User.countryId ?? ""
                self.menuView.setMenuTitle(User.person!.country!)

                UserDefaults.standard.set(User.countryId, forKey: "countryId")
                UserDefaults.standard.set(User.person!.country!, forKey: "countryDefault")
                UserDefaults.standard.set(User.person!.city!, forKey: "cityDefault")
                UserDefaults.standard.set("AllSex", forKey: "sexDefault")
                UserDefaults.standard.set("AllAges", forKey: "ageDefault")
                UserDefaults.standard.set("AllCountries", forKey: "destinationDefault")
                UserDefaults.standard.set("AllMonths", forKey: "monthDefault")
                UserDefaults.standard.synchronize()
                spinner.startAnimating()
                self.navigationDropdownMenu()
                self.firstRequest()
                return
            }

            // Search completion
            searchController.resultComplition = { (rawValue: String, localValue: String) in
                tableView.items[indexPath] = (items[indexPath].0, localValue)

                if indexPath == 0 {
                    countryId = rawValue
                    self.menuView.setMenuTitle(localValue)
                    let value = rawValue == "AllCountries" ? rawValue : localValue
                    UserDefaults.standard.set(value, forKey: "countryDefault")
                    UserDefaults.standard.set(rawValue, forKey: "countryId")
                    self.countryDefault = value

                    self.cityDefault = "AllCities"
                    tableView.items[1] = (items[indexPath + 1].0, self.cityDefault.toCity())
                    UserDefaults.standard.set("AllCities", forKey: "cityDefault")

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
                spinner.startAnimating()
                self.firstRequest()
            }
            self.navigationController?.pushViewController(searchController, animated: true)
        }
        self.navigationItem.titleView = menuView
    }

    @IBAction func addTravel(_ sender: Any) {
        guard User.thirdTravel == "" else {
            MessageBox.showMessage(parent: self, title: NSLocalizedString("Maximum is 3 travels", comment: "Maximum is 3 travels"), message: "")
            return
        }
        let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "TravelNavigationController")
        self.present(profileVC!, animated: true, completion: nil)
    }

    @IBAction func logout(_ sender: Any) {
        MessageBox.showDialog(parent: self, title: NSLocalizedString("Sign out", comment: "Sign out"), message: NSLocalizedString("Do you want to sign out?", comment: "Do you want to sign out?")) {
            Request.logOut {
                let registrationVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterNavigationController")
                self.present(registrationVC!, animated: true, completion: nil)
            }
        }
    }

    // MARK: Collection view delegate
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
        if segue.identifier == "ShowDetail" {
            if let indexPaths = collectionView?.indexPathsForSelectedItems {
                let indexPath = indexPaths[0] as NSIndexPath
                let dvc = segue.destination as! DetailViewController
                dvc.userUid = travelsArray[indexPath.row].uid
            }
        }
    }

    // MARK: Check auth
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
        Request.singleRequest(reference: Request.ref.child("Users").child(User.uid!).queryOrderedByKey(), type: .value, completion: { (snapshot, error) in
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
                    Request.singleRequest(reference: Request.ref.child("Users").child(User.uid!).queryOrderedByKey(), type: .value, completion: { (snapshot, error) in
                        guard error == nil else {return}
                        if let snap = snapshot?.value as? NSDictionary {
                            let json = JSON(snap)
                            let travelsCount = json["firstTravel"].stringValue
                            if travelsCount == "" && UserDefaults.standard.value(forKey: "firstEnter") as? Bool == nil {

                                UserDefaults.standard.set(true, forKey: "firstEnter")
                                UserDefaults.standard.synchronize()

                                let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "TravelNavigationController")
                                DispatchQueue.main.async {
                                    self.present(profileVC!, animated: true)
                                }
                                return
                            }
                            MainViewController.needCheckAuth = false
                            self.navigationDropdownMenu()
                            self.menuView.setMenuTitle(self.countryDefault.toCountry())
                            Request.postToken()
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

    // MARK: Requests
    func getReference() -> DatabaseReference {
        let cityDefault = countryDefault == "AllCountries" ? "AllCities" : self.cityDefault

        var reference = Request.ref.child("Travels").child("AllTravels").child(countryDefault).child(cityDefault).child(ageDefault).child(sexDefault)

        if destinationDefault != "AllCountries" && monthDefault != "AllMonths" {
            reference = Request.ref.child("Travels").child("Match").child(countryDefault).child(cityDefault).child(destinationDefault).child(monthDefault).child(ageDefault).child(sexDefault)

        } else if destinationDefault != "AllCountries" {
            reference = Request.ref.child("Travels").child("Destinations").child(countryDefault).child(cityDefault).child(destinationDefault).child(ageDefault).child(sexDefault)

        } else if monthDefault != "AllMonths" {
            reference = Request.ref.child("Travels").child("Months").child(countryDefault).child(cityDefault).child(monthDefault).child(ageDefault).child(sexDefault)

        }
        return reference
    }

    func firstRequest () {
        var travelsArray: [Travel] = []

        // Last position
        Request.singleRequest(reference: getReference().queryOrdered(byChild: "createdate").queryLimited(toFirst: 1), type: .value) { (snapshot, error) in
            guard error == nil else {print (error as Any); return}

            guard let snapshot = snapshot?.children.allObjects as? [DataSnapshot] else {return}

            guard let dictionary = snapshot.first?.value as? [String : Any] else {
                self.travelsArray = travelsArray
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    spinner.stopAnimating()
                    self.refreshControl.endRefreshing()
                }
                return
            }

            let travel = Travel(dictionary: dictionary as [String : Any])

            self.lastPosition = travel.createDate

            // Get travels
            Request.singleRequest(reference: self.getReference().queryOrdered(byChild: "createdate").queryLimited(toLast: reqLimit), type: .value) { (snapshot, error) in
                guard error == nil else {print (error as Any); return}

                guard let snapshot = snapshot?.children.allObjects as? [DataSnapshot] else {return}

                for snap in snapshot.reversed() {
                    guard let dictionary = snap.value as? [String : Any] else {return}

                    let travel = Travel(dictionary: dictionary as [String : Any])
                    travelsArray.append(travel)

                }
                self.travelsArray = travelsArray

                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    spinner.stopAnimating()
                    self.refreshControl.endRefreshing()
                }
            }

        }
    }

    // Pagination
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        if indexPath.row == (travelsArray.count - 5) {

            guard let endIndex = self.endIndex else {return}
            guard let lastPosition = self.lastPosition else {return}
            guard endIndex > lastPosition else {return}

            // Get more travels
            Request.singleRequest(reference: getReference().queryOrdered(byChild: "createdate").queryEnding(atValue: endIndex - 1).queryLimited(toLast: reqLimit), type: .value, completion: { (snapshot, error) in
                guard error == nil else {print (error as Any); return}
                
                guard let snapshot = snapshot?.children.allObjects as? [DataSnapshot] else {return}
                
                for snap in snapshot.reversed() {
                    guard let dictionary = snap.value as? [String : Any] else {return}
                    
                    let travel = Travel(dictionary: dictionary as [String : Any])
                    self.travelsArray.append(travel)
                    
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            })
        }
    }
}
