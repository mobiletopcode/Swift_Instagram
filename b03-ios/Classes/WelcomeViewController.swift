//
//  AuthViewController.swift
//
//  Created by Bossly on 9/10/16.
//  Copyright © 2016 Bossly. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI

class WelcomeViewController: UIViewController, FIRAuthUIDelegate {

    override func viewDidLoad() {
        // if user authorized, go to main page
        if (FIRAuth.auth()?.currentUser) != nil {
            self.performSegue(withIdentifier: "auth.mute", sender: nil)
        }
    }
    
    // FIRAuthUIDelegate
    func authPickerViewController(for authUI: FIRAuthUI) -> FIRAuthPickerViewController {
        return AuthPickerViewController(nibName: nil, bundle: nil, authUI: authUI)
    }
    
    func authUI(_ authUI: FIRAuthUI, didSignInWith user: FIRUser?, error: Error?) {
        if let errorHandler = error as NSError? {
            switch errorHandler.code {
            case Int(FIRAuthUIErrorCode.userCancelledSignIn.rawValue):
                // User cancel auth
                break;
            case FIRAuthErrorCode.errorCodeOperationNotAllowed.rawValue:
                // Provider disabled on Firebase. Please, go to Firebase control panel and enable it.
                print(errorHandler.localizedDescription)
                self.showError("Current provider is disabled. Please try use another one")
                break;
            default:
                self.showError(errorHandler.localizedDescription)
            }
        } else {

            if let currentUser = FIRAuth.auth()?.currentUser {
                User.collection.child(currentUser.uid).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    // if snapshot is empty, means user is not created yet
                    if snapshot.childrenCount == 0 {
                        
                        // update displayname and photo
                        let userdata = User(currentUser.uid)
                        userdata.name = currentUser.displayName ?? kDefaultUsername
                        userdata.photo = currentUser.photoURL?.absoluteString ?? kDefaultProfilePhoto
                        userdata.saveData()
                    }
                })
            }

            self.performSegue(withIdentifier: "auth", sender: nil)
        }
    }
    
    // Helpers
    
    func showError(_ error:String) {
        let alert = UIAlertController(title: kAlertErrorTitle, message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: kAlertErrorDefaultButton, style: .default) { (action) in })
        self.present(alert, animated: true) {}
    }
    
    // Actions
    @IBAction func buttonPressed(_ sender: AnyObject) {
        let authUI = FIRAuthUI.default()
        authUI?.delegate = self

        /* 
         * Uncommend this lines to add Google and Facebook authorization. But first 
         * enabled it in Firebase Console. More infromation you can find here:
         * https://firebase.google.com/docs/auth/ios/google-signin
         * https://firebase.google.com/docs/auth/ios/facebook-login
         */
        let provides:[FIRAuthProviderUI] = [
//             support Google accounts
             FIRGoogleAuthUI(scopes: ["profile", "email"]),
//             support Facebook accounts
             FIRFacebookAuthUI()
        ]
        
        authUI?.providers = provides
        /* 
         kEulaUrl needs to be set in Config.swift file. required for publishing
         */
        authUI?.tosurl = URL(string:kEulaUrl)
        
        if (FIRAuth.auth()?.currentUser) != nil {
            self.performSegue(withIdentifier: "auth.mute", sender: nil)
        } else {
            let authViewController = authUI!.authViewController()
            
            self.present(authViewController, animated: true) {
                // ..
            }
        }
    }
    
}
