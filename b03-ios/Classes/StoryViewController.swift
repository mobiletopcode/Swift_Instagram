//
//  StoryViewTableViewController.swift
//  Project
//
//  Created by Bossly on 11/8/16.
//  Copyright © 2016 Bossly. All rights reserved.
//

import UIKit
import Firebase

class StoryViewController: UIViewController {
    
    var storyId:String?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let feed = segue.destination as? FeedViewController {
            feed.singleStoryId = self.storyId
        }
    }
}
