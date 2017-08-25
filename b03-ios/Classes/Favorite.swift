//
//  Favorite.swift
//  Project
//
//  Created by Bossly on 9/14/16.
//  Copyright © 2016 Bossly. All rights reserved.
//

import UIKit
import Firebase

class Favorite: ModelBase {

    static func collection(_ userId:String) -> FIRDatabaseReference {
        return FIRDatabase.database().reference().child("\(kDataFavoritesKey)/\(userId)")
    }

    override func parent() -> FIRDatabaseReference {
        return FIRDatabase.database().reference().child("\(kDataFavoritesKey)")
    }
    
    override func loadData(snap: FIRDataSnapshot, with complete: @escaping (Bool) -> Void) {
    }
}
