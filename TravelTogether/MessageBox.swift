//
//  MessageBox.swift
//  TravelTogether
//
//  Created by Dmitry on 13.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import UIKit

class MessageBox {
    
    static func showMessage (parent: UIViewController, title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        parent.present(alertController, animated: true, completion: nil)
    }
    
    static func showDialog (parent: UIViewController, title: String, message: String, complition: @escaping () -> ()) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            complition()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        parent.present(alertController, animated: true, completion: nil)
    }
    
    
}
