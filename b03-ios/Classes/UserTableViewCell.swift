//
//  UserTableViewCell.swift
//  Project
//
//  Created by Bossly on 10/15/16.
//  Copyright © 2016 Bossly. All rights reserved.
//

import UIKit
import Firebase

protocol UserTableViewCellDelegate {
    // required
    func didSelected(userRef:FIRDatabaseReference)
    func didAction(storyRef:FIRDatabaseReference, position:NSInteger)
}

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var profileView: UIImageView?
    @IBOutlet weak var usernameView: UILabel?
    @IBOutlet weak var actionButton: UIButton?
    
    var delegate:UserTableViewCellDelegate?
    var linkedStoryRef:FIRDatabaseReference?
    var cellIndex:NSInteger = -1
    
    private var handler:UInt? = nil
    private var userCache:User?
    
    var userRef:FIRDatabaseReference? {
        willSet {
            resetCell()
            
            // unsubscribe
            if let _handler = handler {
                userRef?.removeObserver(withHandle: _handler)
            }
        }
        didSet {
            // subscribe
            handler = userRef?.observe(.value, with: { (snapshot) in
                let user = User(snapshot)
                self.setupCell(user: user)
            })
        }
    }
    
    private func resetCell() {
        self.usernameView?.text = kDefaultUsername
        self.profileView?.image = #imageLiteral(resourceName: "avatarPlaceholder")
        self.actionButton?.isHidden = true
    }
    
    private func setupCell(user:User) {
        self.userCache = user
        let placeholder = UIImage(named: "avatarPlaceholder")!
        
        // user name
        self.usernameView?.text = user.name
        
        // user profile photo
        self.profileView?.sd_cancelCurrentImageLoad()
        self.profileView?.sd_setImage(with: URL(string:user.photo), placeholderImage: placeholder)
        
        // follow/unfollow button
        self.actionButton?.isHidden = user.isCurrent()
        self.actionButton?.isSelected = user.isFollow
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        resetCell()
        
        // setup onclick action
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onDisplayProfile))
        self.addGestureRecognizer(recognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func onDisplayProfile() {
        if let ref = self.userRef {
            self.delegate?.didSelected(userRef: ref)
        }
    }

    @IBAction func actionButton(sender:Any) {
        
        if let ref = self.linkedStoryRef {
            self.delegate?.didAction(storyRef: ref, position: cellIndex)
        } else {
            // follow/unfollow user
            if let user = userCache {
                if user.isFollow {
                    user.unfollow()
                } else {
                    user.follow()
                }
            }
        }
    }
}
