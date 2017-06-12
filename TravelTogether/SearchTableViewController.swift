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
    func getSearchResult(result: (String?, String?)?, index: Int?)
}

class SearchTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {    
    
    static var delegate: SearchTableViewDelegate?
    
    var index: Int?
    
    let searchBar = UISearchBar()
    let tableView = UITableView()
    let stackView = UIStackView()
    
    var request: ((_ complition: @escaping (_ content: [(String, [(String, String)])]) -> ()) -> Void)?
    
    var contentArray = [(String, [(String, String)])]()
    
    var result: (String?, String?)?
    
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
        cell.textLabel?.text = contentArray[indexPath.section].1[indexPath.row].1
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        result = (contentArray[indexPath.section].1[indexPath.row].0, contentArray[indexPath.section].1[indexPath.row].1)
        SearchTableViewController.delegate?.getSearchResult(result: result, index: index)
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentArray[section].1.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return contentArray[section].0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return contentArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    

}
