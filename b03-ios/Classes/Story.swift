//
//  Story.swift
//
//  Created by Bossly on 9/11/16.
//  Copyright © 2016 Bossly. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class Story : ModelBase {

    static var recents:FIRDatabaseReference {
        get {
            return FIRDatabase.database().reference().child(kDataRecentsKey)
        }
    }

    static var collection:FIRDatabaseReference {
        get {
            return FIRDatabase.database().reference().child(kDataPostKey)
        }
    }
    
    static func createStory(_ user:FIRUser, url:String, video:String) {
        
        // Create a reference to the file you want to upload
        let uid = user.uid
        let curUser = User(uid)
        let now = Date().format(with: kDateFormat)

        curUser.fetchInBackground { (model, success) in
            
            let post = ["user": uid,
                        "time" : now,
                        "image": url,
                        "video": video,
                        "message":""]
            
            // add to post collection
            var ref = Story.collection
            let key = ref.childByAutoId().key
            ref.updateChildValues(["/\(key)": post])
            
            // add to personal feed
            ref = curUser.feed
            ref.updateChildValues(["/\(key)": uid])
            
            // add to uploads list
            curUser.uploads.updateChildValues(["/\(key)": uid])
            
            // add to followers feed
            curUser.followers.observeSingleEvent(of: .value, with: { (snapshot) in
                for item in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    User(item.key).feed.updateChildValues(["/\(key)": uid])
                }
            })
        }
    }
    
    static func removeStory(_ uid:String) {
        Story(uid).fetchInBackground { (data, success) in
            if let story = data as? Story {
                let user = User(story.userId)
                story.ref.removeAllObservers()
                story.ref.removeValue()
                
                user.feed.child(uid).removeValue()
                user.uploads.child(uid).removeValue()

                user.followers.observeSingleEvent(of: .value, with: { (snapshot) in
                    for item in snapshot.children.allObjects as! [FIRDataSnapshot] {
                        User(item.key).feed.child(uid).removeValue()
                    }
                })
            }
        }
    }
    
    // MARK: - Model
    var userRef:FIRDatabaseReference?
    
    var time:Date? = nil
    var media:String = ""    
    var userId:String = ""
    var videoUrl:URL! = nil

    var userName:String = kDefaultUsername
    var userPhoto:String = kDefaultProfilePhoto

    override func parent() -> FIRDatabaseReference {
        return Story.collection
    }
    
    override func loadData(snap: FIRDataSnapshot, with complete:@escaping (Bool) -> Void) {
        
        if let value = snap.value as? [String:Any] {
            self.media = value["image"] as! String
            self.userId = value["user"] as! String
            
            if let timeString = value["time"] as? String {
                self.time = Date(dateString: timeString, format: kDateFormat)
            }
            
            if let videoAbsolute = value["video"] as? String {
                if videoAbsolute.characters.count > 0 {
                    self.videoUrl = URL(string: videoAbsolute)
                }
            }
            
            // remove previous observers
            userRef?.removeAllObservers()
            
            // add new observer
            userRef = User.collection.child(self.userId)
            userRef?.keepSynced(true)

            // update user_info and update in realtime
            userRef?.observe(.value, with: { (snap) in
                let user = User(snap)
                self.userName = user.name
                self.userPhoto = user.photo
            })

            complete(true)
        } else {
            complete(false)
        }
    }
    
    deinit {
        userRef?.removeAllObservers()
    }
}
