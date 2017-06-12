//
//  SearchTableViewController.swift
//  TravelTogether
//
//  Created by Dmitry on 10.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit
import SwiftyJSON

class SearchTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {    
    
    let searchBar = UISearchBar()
    let tableView = UITableView()
    let stackView = UIStackView()
    
    var request: ((_ complition: @escaping (_ JSON: JSON) -> ()) -> Void)?
    
    var url: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
        spinner.startAnimating()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchTableViewCell")
        
        if let request = request {
            searchRequest(request: request)
        } else {
            spinner.stopAnimating()
        }
    }
    
    func searchRequest(request: (_ complition: @escaping (_ JSON: JSON) -> ()) -> Void) {
        request { (json) in
            spinner.stopAnimating()
            print (json)
        }
    }
    
    func setupScreen() {
        let topConstant = UIApplication.shared.statusBarFrame.height + (self.navigationController?.navigationBar.frame.height ?? 0)
        view.addSubview(stackView)
        stackView.addArrangedSubview(searchBar)
        stackView.addArrangedSubview(tableView)
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: topConstant).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        addSpinner(view)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell")!
        cell.textLabel?.text = "123"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    

}
