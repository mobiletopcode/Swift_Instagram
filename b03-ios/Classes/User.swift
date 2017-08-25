//
//  User.swift
//  Project
//
//  Created by Bossly on 10/13/16.
//  Copyright © 2016 Bossly. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class User: ModelBase {
    
    private static var _current:User?
    
    static var collection:FIRDatabaseReference {
        get {
            return FIRDatabase.database().reference().child(kUsersKey)
        }
    }
    
    static var current:User? {
        get {
            if let auth = FIRAuth.auth()?.currentUser {
                if _current == nil || auth.uid != _current!.ref.key {
                    _current = User(auth.uid)
                    _current?.fetchInBackground(completed: { (model, success) in
                    })
                }
                
                return _current
            } else {
                return nil
            }
        }
    }

    private var _isFollowed:Bool = false
    
    var name:String = kDefaultUsername
    var photo:String = kDefaultProfilePhoto
    var token:String?
    var followersCount:UInt = 0
    var followingsCount:UInt = 0
    var postsCount:UInt = 0
    var isFollow:Bool {
        get { return _isFollowed }
    }
    
    // stories I posted
    var feed:FIRDatabaseReference {
        get {
            return FIRDatabase.database().reference().child("\(kUserFeedKey)/\(self.ref.key)")
        }
    }
    
    var uploads:FIRDatabaseReference {
        get {
            return FIRDatabase.database().reference().child("\(kUploadsKey)/\(self.ref.key)")
        }
    }

    // posts I liked
    var favorites:FIRDatabaseReference {
        get {
            return FIRDatabase.database().reference().child("\(kDataFavoritesKey)/\(self.ref.key)")
        }
    }

    // followers - people who follow me
    var followers:FIRDatabaseReference {
        get {
            return self.ref.child(kFollowersKey)
        }
    }

    // followigns - people followed by me
    var followings:FIRDatabaseReference {
        get {
            return self.ref.child(kFollowinsKey)
        }
    }
    
    func follow() {
        if let current = User.current, self.ref.key != current.ref.key {
            current.followings.child(self.ref.key).setValue("true")
            self.followers.child(current.ref.key).setValue("true")
            _isFollowed = true
            
            fetchInBackground(completed: { (model, success) in
                // update data
            })
        }
    }
    
    func unfollow() {
        if let current = User.current, self.ref.key != current.ref.key {
            current.followings.child(self.ref.key).removeValue()
            self.followers.child(current.ref.key).removeValue()
            _isFollowed = false

            fetchInBackground(completed: { (model, success) in
                // update data
            })
        }
    }

    func isCurrent() -> Bool {
        if let current = User.current, self.ref.key != current.ref.key {
            return false
        } else {
            return true
        }
    }

    override func parent() -> FIRDatabaseReference {
        return User.collection
    }
    
    override func loadData(snap: FIRDataSnapshot, with complete: @escaping (Bool) -> Void) {
        if let value = snap.value as? [String:Any] {
            self.name = value["name"] as? String ?? kDefaultUsername
            self.photo = value["photo"] as? String ?? kDefaultProfilePhoto
            
            _isFollowed = snap.childSnapshot(forPath: "\(kFollowersKey)/\(User.current!.ref.key)").exists()
            
            complete(true)
        } else {
            complete(false)
        }
    }
    
    func saveData() {
        self.ref.updateChildValues(["name":self.name,
                                    "photo":self.photo])
    }
    
    func save(_ token:String) {
        guard let deviceUid = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        
        self.ref.child(kTokensKey).child(deviceUid).setValue(token)
    }
}
