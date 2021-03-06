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
    
    @IBAction func forgotPassword(_ sender: Any) {
        let title = NSLocalizedString("Reset password?", comment: "Reset password?")
        let message = NSLocalizedString("Information on how to reset the password will be sent to the email address", comment: "Reset info")
        MessageBox.showTextField(parent: self, title: title, message: message, placeholder: "email") { (text) in
            guard let text = text else {return}
            Auth.auth().sendPasswordReset(withEmail: text, completion: { (error) in
                if error != nil {
                    let errorMessage = error?.localizedDescription ?? "Reset password error"
                    MessageBox.showMessage(parent: self, title: NSLocalizedString("Error", comment: "Error"), message: errorMessage)
                }
                MessageBox.showMessage(parent: self, title: NSLocalizedString("Success", comment: "Success"), message: NSLocalizedString("Check your email", comment: "Check your email"))
            })
        }        
    }
    
    
    @IBAction func onRegister(_ sender: Any) {
        
        guard let emailUser = emailTextField.text, let password = passwordTextField.text else {return}
        
        if segmentedControl.selectedSegmentIndex == 0 {
            
            Auth.auth().signIn(withEmail: emailUser, password: password, completion: { (user, error) in
                guard error == nil else {self.errorHandling(error: error!); return}
                guard let uid = user?.uid else {print (error as Any); return}
                
                User.uid = uid
                User.email = user?.email
                
                self.navigationController?.dismiss(animated: true, completion: nil)
                print ("success Sign In with email")
            })
        } else {
            
            Auth.auth().createUser(withEmail: emailUser, password: password, completion: { (user, error) in
                guard error == nil else {self.errorHandling(error: error!); return}
                print ("success Register with email")
                
                Auth.auth().signIn(withEmail: emailUser, password: password, completion: { (user, error) in
                    guard error == nil else {print (error as Any); return}
                    guard let uid = user?.uid else {print (error as Any); return}
                    
                    User.uid = uid
                    User.email = user?.email
                    
                    Request.updateChildValue(reference: Request.ref.child("Users").child(uid), value: ["email": emailUser], completion: {})
                    
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
            let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
            Auth.auth().signIn(with: credentials, completion: { (user, error) in
                guard error == nil else {self.errorHandling(error: error!); return}
                User.email = user?.email
                User.uid = user?.uid                
                
                if let uid = User.uid {
                    if let email = User.email {
                        
                        Request.updateChildValue(reference: Request.ref.child("Users").child(uid), value: ["email": email], completion: {})
                    } else {
                        
                        Request.singleRequest(reference: Request.ref.child("Users").child(uid).queryOrderedByKey(), type: .value, completion: { (snapshot, error) in
                            guard error == nil else {return}
                            if let snap = snapshot?.value as? NSDictionary {
                                let json = JSON(snap)
                                let email = json["email"].stringValue
                                if email == "" {
                                    DispatchQueue.main.async {
                                        self.enterEmail(uid: uid)
                                        return
                                    }
                                } else {
                                    User.email = email
                                    DispatchQueue.main.async {
                                        self.dismiss(animated: true, completion: nil)
                                        print ("Facebook sign in success")
                                    }
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.enterEmail(uid: uid)
                                    return
                                }
                            }
                        })
                    }
                }
            })
        }
    }
    
    func enterEmail(uid: String) {
        MessageBox.showTextField(parent: self, title: NSLocalizedString("Enter your email", comment: "Enter your email"), message: "", placeholder: "email", complition: { (email) in
            if let email = email {
                if email != "" {
                    User.email = email
                    Request.updateChildValue(reference: Request.ref.child("Users").child(uid), value: ["email": email], completion: {
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                            print ("Facebook sign in success")
                        }
                    })
                } else {
                    self.enterEmail(uid: uid)
                }
            } else {
                Request.logOut{}
            }
        })
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
    
    @IBAction func onSegmentClick(_ sender: Any) {
        let buttonText = segmentedControl.selectedSegmentIndex == 0 ? NSLocalizedString("Sign in", comment: "Sign in") : NSLocalizedString("Register", comment: "Register")
        loginRegButton.setTitle(buttonText, for: UIControlState())
    }
    
    
}
