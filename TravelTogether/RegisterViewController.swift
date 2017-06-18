//
//  RegisterViewController.swift
//  PaperModels
//
//  Created by Dmitry on 22.04.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit
import SwiftyJSON

class RegisterViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate, DismissVC {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loginRegButton: UIButton!
    var destinationVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppDelegate.delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        passwordTextField.isSecureTextEntry = true
        
        scrollView.delaysContentTouches = false
        //let tapRecognaiser = UITapGestureRecognizer(target: self, action: #selector(didTap))
        //scrollView.addGestureRecognizer(tapRecognaiser)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func logOut(_ sender: Any) { 
        MessageBox.showDialog(parent: self, title: NSLocalizedString("Sign out", comment: "Sign out"), message: NSLocalizedString("Do you want to sign out?", comment: "Do you want to sign out?")) {
            let firebaseAuth = FIRAuth.auth()
            do {
                try firebaseAuth?.signOut()
                User.email = nil
                User.uid = nil
                User.displayName = nil
                print ("Sign out succes")                
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
    }
    @IBAction func onRegister(_ sender: Any) {
        
        guard let emailUser = emailTextField.text, let password = passwordTextField.text else {return}
        
        if segmentedControl.selectedSegmentIndex == 0 {
            
            FIRAuth.auth()?.signIn(withEmail: emailUser, password: password, completion: { (user, error) in
                guard error == nil else {self.errorHandling(error: error!); return}
                guard let uid = user?.uid else {print (error as Any); return}
                
                User.uid = uid
                User.email = user?.email
                User.displayName = user?.displayName
                
                self.navigationController?.dismiss(animated: true, completion: nil)
                print ("success Sign In with email")
            })
        } else {
            FIRAuth.auth()?.createUser(withEmail: emailUser, password: password, completion: { (user, error) in
                guard error == nil else {self.errorHandling(error: error!); return}
                print ("success Register with email")
                
                FIRAuth.auth()?.signIn(withEmail: emailUser, password: password, completion: { (user, error) in
                    guard error == nil else {print (error as Any); return}
                    guard let uid = user?.uid else {print (error as Any); return}
                    
                    User.uid = uid
                    User.email = user?.email
                    User.displayName = user?.displayName
                    
                    var value = [AnyHashable : Any]()
                    if let displayName = User.displayName {
                        value = ["email": emailUser, "name": displayName]
                    } else {
                        value = ["email": emailUser]
                    }
                    
                    Request.updateChildValue(reference: Request.ref.child("Users").child(uid), value: value, complition: {})
                    
                    self.navigationController?.dismiss(animated: true, completion: nil)
                    print ("success Sign In with email")
                })
            })
        }
        
    }
    
     @IBAction func facebookLogin(_ sender: Any) {
        
        FBSDKLoginManager().logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            guard error == nil else {self.errorHandling(error: error!); return}
            guard let result = result?.token else {return}
            guard let accessTokenString = result.tokenString else {return}
            let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
            FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
                guard error == nil else {self.errorHandling(error: error!); return}
                User.email = user?.email
                User.uid = user?.uid
                User.displayName = user?.displayName
                
                if let uid = User.uid ,let email = User.email, let displayName = User.displayName {
                    Request.updateChildValue(reference: Request.ref.child("Users").child(uid), value: ["email": email, "name": displayName], complition: {})
                } else if let uid = User.uid, let email = User.email {
                    Request.updateChildValue(reference: Request.ref.child("Users").child(uid), value: ["email": email], complition: {})
                } else if let uid = User.uid, let displayName = User.displayName {
                    Request.updateChildValue(reference: Request.ref.child("Users").child(uid), value: ["name": displayName], complition: {})
                }
                
                //FirstViewController.delegate?.fillTableView()
                self.dismiss(animated: true, completion: nil)
                print ("Facebook sign in success")
            })
            
        }
    }
    
    @IBAction func googleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }    
    
    
    func errorHandling (error: Error) {
        print (error.localizedDescription)
        if error.localizedDescription.contains("The password is invalid or the user does not have a password") {
            MessageBox.showMessage(parent: self, title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("The password is invalid", comment: "The password is invalid"))
        } else if error.localizedDescription.contains("The email address is badly formatted") {
            MessageBox.showMessage(parent: self, title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("The email address is badly formatted", comment: "The email address is badly formatted"))
        } else if error.localizedDescription.contains("The password must be 6 characters long or more") {
            MessageBox.showMessage(parent: self, title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("The password must be 6 characters long or more", comment: "The password must be 6 characters long or more"))
        } else if error.localizedDescription.contains("The email address is already in use by another account") {
            MessageBox.showMessage(parent: self, title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("The email address is already in use by another account", comment: "The email address is already in use by another account"))
        } else {
            MessageBox.showMessage(parent: self, title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Unknown error", comment: "Unknown error"))
        }
    }
    
    func dismissVC() {
        //FirstViewController.delegate?.fillTableView()
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func didTap() {
        self.view.endEditing(true)
    }
    
    @IBAction func onBackClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onSegmentClick(_ sender: Any) {
        let buttonText = segmentedControl.selectedSegmentIndex == 0 ? NSLocalizedString("Sign in", comment: "Sign in") : NSLocalizedString("Register", comment: "Register")
        loginRegButton.setTitle(buttonText, for: UIControlState())
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
