//
//  ViewController.swift
//  gameofchats
//
//  Created by Brian Voong on 6/24/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import Firebase
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class MessagesController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    let cellId = "Cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        refreshControl.backgroundColor = .white
        refreshControl.addTarget(self, action: #selector(observeUserMessages), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        let userCell = UINib(nibName: "UserCell", bundle: nil)        
        tableView.register(userCell, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {        
        guard let uid = User.uid else {return}
        
        let message = self.messages[indexPath.row]
        
        if let chatPartnerId = message.chatPartnerId() {
            Request.removeValue(reference: Request.ref.child("UserMessages").child(uid).child(chatPartnerId), completion: { 
                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadOfTable()
            })            
        }
    }
    
    func observeUserMessages() {
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        guard let uid = User.uid else {return}
        
        let ref = Request.ref.child("UserMessages").child(uid)
        Request.observeRequest(reference: ref, type: .childAdded) { (snapshot, error) in
            guard error == nil else {return}
            guard let userId = snapshot?.key else {return}
            
            Request.observeRequest(reference: Request.ref.child("UserMessages").child(uid).child(userId).queryLimited(toLast: 1), type: .childAdded, completion: { (snapshot, error) in
                guard error == nil else {return}
                
                if let dictionary = snapshot?.value as? [String: AnyObject] {
                    let message = Message(dictionary: dictionary)
                    
                    if let chatPartnerId = message.chatPartnerId() {
                        self.messagesDictionary[chatPartnerId] = message
                    }
                    self.attemptReloadOfTable()
                }
            })
        }
        
        Request.observeRequest(reference: ref, type: .childRemoved) { (snapshot, error) in
            guard error == nil else {return}
            guard let snapshot = snapshot else {return}
            print(snapshot.key)
            print(self.messagesDictionary)
            
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
        }
        
        
    }    
    
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    
    func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            return message1.timestamp?.int32Value > message2.timestamp?.int32Value
        })
        
        DispatchQueue.main.async(execute: {
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell        
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let chatPartnerId = message.chatPartnerId() else {return}
        
        let ref = Request.ref.child("Users").child(chatPartnerId)
        Request.singleRequest(reference: ref, type: .value) { (snapshot, error) in
            guard error == nil else {return}
            guard let dictionary = snapshot?.value as? [String: AnyObject] else {return}            
            var user = User(dictionary: dictionary)
            user.uid = chatPartnerId            
            self.showChatControllerForUser(user)
        }
    }    
    
    func showChatControllerForUser(_ user: User) {
        let chatViewController = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatViewController.user = user
        navigationController?.pushViewController(chatViewController, animated: true)
    }    
    
    
}

