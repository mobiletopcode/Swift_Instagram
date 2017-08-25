//
//  Comment.swift
//
//  Created by Bossly on 9/11/16.
//  Copyright © 2016 Bossly. All rights reserved.
//

import UIKit
import Firebase

class Comment : ModelBase {

    static var collection:FIRDatabaseReference {
        get {
            return FIRDatabase.database().reference().child(kDataCommentKey)
        }
    }
    
    static func sendComment(_ comment:String!, storyKey:String!) {
        
        let commentsRef:FIRDatabaseReference = Comment.collection.child(storyKey)
        let key:String = commentsRef.childByAutoId().key
        
        if let user = User.current {
            let username:String = user.name
            let profilePhoto = user.photo
            let now = Date().format(with: kDateFormat)
            
            let post:[String:Any] = ["message": comment,
                                     "time" : now,
                                     "profile_id" : user.ref.key,
                                     "profile_name": username,
                                     "profile_image" : profilePhoto]
            
            let commentValues:[String:Any] = ["/\(key)": post]
            commentsRef.updateChildValues(commentValues)
        }
    }
    
    override func parent() -> FIRDatabaseReference {
        return Comment.collection
    }

    override func loadData(snap: FIRDataSnapshot, with complete: @escaping (Bool) -> Void) {
        // do nothing
    }
}
