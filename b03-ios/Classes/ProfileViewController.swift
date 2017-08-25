//
//  SecondViewController.swift
//
//  Created by Bossly on 9/10/16.
//  Copyright © 2016 Bossly. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class ThumbnailCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView?
}

class ProfileInfoViewCell : UICollectionReusableView {
    @IBOutlet weak var lblFollowingsCount:UILabel?
    @IBOutlet weak var lblFollowersCount:UILabel?
    @IBOutlet weak var lblPostsCount:UILabel?
    
    @IBOutlet weak var pvPhoto:ProfileView?
    @IBOutlet weak var lblUsername:UILabel?
}

class FavoriteFeedViewController : UIViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let feed = segue.destination as? FeedViewController, let user = FIRAuth.auth()?.currentUser {
            feed.collection = User(user.uid).favorites
        }
    }
}

class ProfileViewController: UICollectionViewController {
    
    var activities:NSMutableArray = []
    var currentUser:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = FIRAuth.auth()?.currentUser {
            // load user profile and keep tracking update
            currentUser = User(user.uid)
            currentUser?.ref.observe(.value, with: { (snap) in
                self.currentUser?.followersCount = snap.childSnapshot(forPath: kFollowersKey).childrenCount
                self.currentUser?.followingsCount = snap.childSnapshot(forPath: kFollowinsKey).childrenCount
                self.currentUser?.loadData(snap: snap, with: { (success) in
                    self.displayUserInfo()
                })
            })

            // load favorites/likes collection
            loadActivity(user.uid)
        }

        // hide back button text
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func displayUserInfo() {
        self.navigationItem.title = self.currentUser?.name
        self.collectionView?.reloadData()
    }
    
    func loadActivity(_ userId:String) {
        
        let favorites = User(userId).uploads
        let ref = favorites.queryOrderedByValue()

        // bind items, and update collection 
        ref.observe(.value, with: { (snapshot) -> Void in
            self.activities = NSMutableArray(array:snapshot.children.allObjects)
            self.collectionView?.reloadData()
        })
    }
    
    @IBAction func logOut() {
        try! FIRAuth.auth()!.signOut()
        
        // show login page 
        _ = self.tabBarController?.navigationController?.popToRootViewController(animated: true)
    }

    // MARK: - Table view data source

    // Layout views in kFavoritesColumns columns
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.size.width/kFavoritesColumns - 1 // minus 1px padding
        return CGSize(width: cellWidth, height: cellWidth)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.activities.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var profileView:ProfileInfoViewCell! = nil
        
        if kind == UICollectionElementKindSectionHeader {
            profileView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Cell", for: indexPath) as! ProfileInfoViewCell
            
            profileView.lblFollowingsCount?.text = "\(self.currentUser?.followingsCount ?? 0)"
            profileView.lblFollowersCount?.text = "\(self.currentUser?.followersCount ?? 0)"
            profileView.lblPostsCount?.text = "\(self.activities.count)"
            profileView.lblUsername?.text = currentUser?.name
            
            if let photo = URL(string:currentUser!.photo) {
                profileView.pvPhoto?.sd_setImage(with: photo, completed: { (image, error, cache, url) in
                    profileView.pvPhoto?.layoutSubviews()
                })
            }
        }
        
        return profileView
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
            as! ThumbnailCollectionViewCell
        
        // Configure the cell
        let r:FIRDataSnapshot = self.activities.object(at: (indexPath as NSIndexPath).row) as! FIRDataSnapshot
        let story = Story(r.key)
        
        story.fetchInBackground { (model, success) in
            cell.imageView?.setIndicatorStyle(.gray)
            cell.imageView?.setShowActivityIndicator(true)
            cell.imageView?.sd_setImage(with: URL(string:story.media))
        }
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let feed = segue.destination as? StoryViewController {
            if let indexPath = self.collectionView?.indexPathsForSelectedItems?.first {
                let r:FIRDataSnapshot = self.activities.object(at: (indexPath as NSIndexPath).row) as! FIRDataSnapshot
                feed.storyId = r.key
            }
        }
    }

}

