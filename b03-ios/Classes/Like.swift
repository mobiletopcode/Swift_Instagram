//
//  Like.swift
//
//  Created by Bossly on 9/14/16.
//  Copyright © 2016 Bossly. All rights reserved.
//

import UIKit
import Firebase

class Like: ModelBase {
    
    static var collection:FIRDatabaseReference {
        get {
            return FIRDatabase.database().reference().child(kDataLikeKey)
        }
    }
    
    static func story(_ story:FIRDatabaseReference!) {
        let likesRef = Like.collection
        
        if let userid = FIRAuth.auth()?.currentUser?.uid {
            let likeRef = likesRef.child("\(story.key)/\(userid)")
            
            likeRef.updateChildValues(["liked":true])
            
            // store what I like
            User(userid).favorites.child(story.key).setValue(true)
        }
    }
    
    static func toggle(_ story:FIRDatabaseReference!) {
        let likesRef = Like.collection
        
        if let userid = FIRAuth.auth()?.currentUser?.uid {
            let likeRef = likesRef.child("\(story.key)/\(userid)")
            
            likeRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let value = snapshot.value as? [String:Any] {
                    let liked = value["liked"] as? Bool ?? false
                    likeRef.updateChildValues(["liked":!liked])
                    
                    // store what I like
                    if liked == false {
                        User(userid).favorites.child(story.key).setValue(true)
                    } else {
                        User(userid).favorites.child(story.key).removeValue()
                    }
                } else {
                    // if data not exist, set as liked
                    likeRef.updateChildValues(["liked":true])
                    User(userid).favorites.child(story.key).setValue(true)
                }
            })
        }
    }
    
    override func parent() -> FIRDatabaseReference {
        return Like.collection
    }
    
    override func loadData(snap: FIRDataSnapshot, with complete: @escaping (Bool) -> Void) {
        
    }    
}
