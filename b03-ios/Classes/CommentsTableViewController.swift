//
//  CommentsTableViewController.swift
//  b03-ios
//
//  Created by Bossly on 9/11/16.
//  Copyright © 2016 Bossly. All rights reserved.
//

import UIKit
import Firebase

class CommentsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UserTableViewCellDelegate {
    
    var comments:NSMutableArray! = nil
    var storyId:String! = ""
    
    @IBOutlet weak var keyboardConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentText: UITextView!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.comments = NSMutableArray()
        let query = Comment.collection.child(self.storyId).queryOrderedByKey()

        // Listen for new posts in the Firebase database
        query.observe(.childAdded, with: { (snapshot) -> Void in
            DispatchQueue.main.async(execute: { 
                self.comments.add(snapshot)
                let lastIndex = IndexPath(row: self.comments.count-1, section: 0)
                self.tableView.insertRows(at: [lastIndex], with:.bottom)
                self.tableView.scrollToRow(at: lastIndex, at: .bottom, animated: false)
            })
        })
        
        self.tableView.estimatedRowHeight = 250
        self.tableView.rowHeight = UITableViewAutomaticDimension

        NotificationCenter.default
            .addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default
            .addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.commentText.becomeFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let profileCtrl = segue.destination as? ProfileFeedViewController {
            let user = sender as? FIRDatabaseReference
            profileCtrl.user = user
        }
    }
    
    func keyboardWillShow(_ notification:Notification) {
        let rect:CGRect = ((notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        let duration = ((notification as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
        self.keyboardConstraint.constant = -rect.height
        
        UIView.animate(withDuration: duration!, animations: { 
            self.view.layoutSubviews()
        }) 
    }

    func keyboardWillHide(_ notification:Notification) {
        let duration = ((notification as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
        self.keyboardConstraint.constant = 0
        
        UIView.animate(withDuration: duration!, animations: {
            self.view.layoutSubviews()
        }) 
    }

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CommentTableViewCell

        // Configure the cell...
        if let comment = self.comments.object(at: (indexPath as NSIndexPath).row) as? FIRDataSnapshot {
            cell.displayComment(comment)
            cell.delegate = self
        }

        return cell
    }
    
    @IBAction func onSend(_ sender: AnyObject) {
        if let commentText = self.commentText.text {
            Comment.sendComment(commentText, storyKey: self.storyId)
        }
        
        self.commentText.text = nil
    }
    
    /* UserTableViewCellDelegate */
    
    func didSelected(userRef: FIRDatabaseReference) {
        self.performSegue(withIdentifier: "show.profile", sender: userRef)
    }
    
    func didAction(storyRef: FIRDatabaseReference, position:NSInteger) {
        // none
    }
}
