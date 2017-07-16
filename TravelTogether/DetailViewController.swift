//
//  DetailViewController.swift
//  TravelTogether
//
//  Created by Dmitry on 10.07.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit
import Firebase

class DetailViewController: UIViewController {
    
    var reference: FIRDatabaseReference?
    
    var userUid: String? {
        didSet {
            guard user == nil else {return}
            guard let uid = userUid else {return}
            reference = Request.ref.child("Users").child(uid)
        }
    }
    var user: User? {
        didSet {
            guard let uid = user?.uid else {return}
            reference = Request.ref.child("Users").child(uid)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        reference?.removeAllObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let reference = self.reference else {return}
        
        Request.observeRequest(reference: reference, type: .childChanged, completion: { (snapshot, error) in
            guard snapshot?.key == "status" else {return}
            print (snapshot?.value)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let reference = self.reference else {return}
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        Request.singleRequest(reference: reference, type: .value) { (snapshot, error) in
            guard error == nil else {print (error?.localizedDescription as Any); return}
            guard let dictionary = snapshot?.value as? [String: AnyObject] else {return}
            self.user = User(dictionary: dictionary)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? ChatViewController {
            dvc.user = user
        }        
    }
}
