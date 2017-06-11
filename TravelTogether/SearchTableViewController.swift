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
    
    var url: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchTableViewCell")
        
        url = "https://firebasestorage.googleapis.com/v0/b/traveltogether-3e48a.appspot.com/o/countriesToCities.json?alt=media&token=f129b094-d680-4702-b1cc-9aeed9d7943e"
        
        Request.getJSON(url: url) { (json) in
            
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
