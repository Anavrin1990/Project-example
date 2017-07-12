//
//  DetailViewController.swift
//  TravelTogether
//
//  Created by Dmitry on 10.07.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var userUid: String?
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let uid = userUid else {return}
        
        Request.singleRequest(reference: Request.ref.child("Users").queryOrderedByKey().queryEqual(toValue: uid), type: .value) { (snapshot, error) in
            guard error == nil else {print (error?.localizedDescription as Any); return}
            Parsing.usersParse(snapshot, complition: { (user) in
                self.user = user
            })
        }
    }

    @IBAction func onChatClick(_ sender: Any) {
        guard let user = self.user else {return}
        let chatLogController = storyboard?.instantiateViewController(withIdentifier: "ChatLogController") as! ChatLogController
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
}
