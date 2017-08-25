//
//  ProfileFeedViewController.swift
//  Project
//
//  Created by Oleg Baidalka on 09/04/2017.
//  Copyright © 2017 Bossly. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class ProfileFeedViewController : UIViewController {
    
    @IBOutlet weak var profileView: UIImageView?
    @IBOutlet weak var profileNameLabel: UILabel?
    @IBOutlet weak var followButton: UIButton!
    
    private var cachedUser:User?
    var user:FIRDatabaseReference? {
        didSet {
            user?.observeSingleEvent(of: .value, with: { (snap) in
                self.cachedUser = User(snap)
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let feed = segue.destination as? FeedViewController {
            feed.searchbarHidden = true
            // wait while data been set 
            feed.beginUpdate = false
            
            self.user?.observe(.value, with: { (snap) in
                let user = User(snap)
                let username = user.name.lengthOfBytes(using: .utf8) > 0
                    ? user.name : kDefaultUsername
                // hide the button is not personal feed mode
                self.followButton.isHidden = user.isCurrent()
                feed.beginUpdate = true
                feed.collection = user.uploads
                feed.loadData()
                
                self.title = username
                self.profileNameLabel?.text = username
                
                if let photo = URL(string:user.photo) {
                    self.profileView?.sd_setImage(with: photo, completed: {
                        (image, error, cache, url) in
                        self.profileView?.layoutSubviews()
                    })
                }
                
                self.followButton.isSelected = user.isFollow
            })
        }
    }
    
    @IBAction func followClicked(_ sender: Any) {
        if let user = self.cachedUser {
            if user.isFollow {
                user.unfollow()
                self.followButton.isSelected = false
            } else {
                user.follow()
                self.followButton.isSelected = true
            }
        }
    }
}
