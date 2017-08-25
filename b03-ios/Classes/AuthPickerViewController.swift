//
//  AuthPickerViewController.swift
//  Project
//
//  Created by Bossly on 10/5/16.
//  Copyright © 2016 Bossly. All rights reserved.
//

import UIKit
import FirebaseAuthUI

class HeaderView : UIView {
    
    @IBAction func onAgreementClicked(_ sender: Any) {
        UIApplication.shared.openURL(URL(string:kEulaUrl)!)
    }

}

class AuthPickerViewController: FIRAuthPickerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let headerViews = Bundle.main.loadNibNamed("AuthLogoView", owner: self, options: nil)
        
        if let headerView = headerViews?.first as? HeaderView {
            self.view.addSubview(headerView)
        }
        
        self.view.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = self.title
    }
}
