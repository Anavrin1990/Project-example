//
//  SearchTableViewController.swift
//  TravelTogether
//
//  Created by Dmitry on 10.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol SearchTableViewDelegate {
    func getSearchResult(name: String?, result: (String, String))
}

class SearchTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {    
    
    static var delegate: SearchTableViewDelegate?
    
    var searchTextIsEmpty = true
    
    var name: String?
    
    let searchBar = UISearchBar()
    let tableView = UITableView()
    let stackView = UIStackView()
    var withTopConstraint = true
    
    var request: ((_ complition: @escaping (_ content: [(String, [(String, String)])]) -> ()) -> Void)? // Выполняемая функция
    
    var contentArray = [(String, [(String, String)])]()
    var filteredContentArray = [(String, String)]()
    
    var result: (String, String)?
    var resultComplition: (((String, String)) -> ())?
    
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
    
    func searchRequest(request: (_ complition: @escaping (_ content: [(String, [(String, String)])]) -> ()) -> Void) {
        request { (content) in
            self.contentArray = content
            
            DispatchQueue.main.async {
                spinner.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
    
    func setupScreen() {
        let bottomConstant = self.tabBarController?.tabBar.frame.height
        let topConstant = withTopConstraint ? UIApplication.shared.statusBarFrame.height + (self.navigationController?.navigationBar.frame.height ?? 0) : 0
        view.addSubview(stackView)
        stackView.addArrangedSubview(searchBar)
        stackView.addArrangedSubview(tableView)
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: topConstant).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(bottomConstant ?? 0)).isActive = true
        addSpinner(view)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell")!
        cell.textLabel?.text = searchTextIsEmpty ? contentArray[indexPath.section].1[indexPath.row].1 : filteredContentArray[indexPath.row].1
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
       
        result = searchTextIsEmpty ? (contentArray[indexPath.section].1[indexPath.row].0, contentArray[indexPath.section].1[indexPath.row].1) : (filteredContentArray[indexPath.row].0, filteredContentArray[indexPath.row].1)
        
        if let resultComplition = resultComplition {
             resultComplition(result!)
        }
        SearchTableViewController.delegate?.getSearchResult(name: name, result: result!)
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchTextIsEmpty ? contentArray[section].1.count : filteredContentArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return searchTextIsEmpty ? contentArray[section].0 : nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchTextIsEmpty ? contentArray.count : 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return searchTextIsEmpty ? 30 : 0
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTextIsEmpty = searchText.isEmpty
        filteredContentArray = []
        
        for item in contentArray {
            for value in item.1 {
                if value.1.lowercased().contains(searchText.lowercased()) {
                    filteredContentArray.append(value.0, value.1)
                }
            }
        }
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchTextIsEmpty = true
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        searchBar.text = ""
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    

    
    
    
    
    
    
    

}
