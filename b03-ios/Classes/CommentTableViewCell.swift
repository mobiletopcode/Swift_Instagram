//
//  CommentTableViewCell.swift
//  b03-ios
//
//  Created by Bossly on 9/11/16.
//  Copyright © 2016 Bossly. All rights reserved.
//

import UIKit
import Firebase

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileView: UIImageView?
    @IBOutlet weak var textView: UITextView?
    @IBOutlet weak var timeView: UILabel?
    
    var delegate:UserTableViewCellDelegate?
    fileprivate var user:User?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.textView?.textContainerInset = UIEdgeInsets.zero
        
        if let profile = self.profileView {
            profile.setIndicatorStyle(.gray)
            profile.setShowActivityIndicator(true)

            // setup onclick action
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(onDisplayProfile))
            profile.addGestureRecognizer(recognizer)
        }
    }
    
    func onDisplayProfile() {
        if let ref = self.user?.ref {
            self.delegate?.didSelected(userRef: ref)
        }
    }
    
    func displayComment(_ comment:FIRDataSnapshot) {
        if let value = comment.value as? [String:Any] {
            
            if let userid = value["profile_id"] as? String {
                user = User(userid)
            }
            
            let text = NSMutableAttributedString()
            let placeholder = UIImage(named: "avatarPlaceholder")
            
            if let profile = value["profile_name"] as? String {
                let attrs = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: kCommentFontSize)]
                text.append(NSAttributedString(string:"\(profile) ", attributes: attrs))
            }
            
            if let message = value["message"] as? String {
                let attrs = [NSFontAttributeName : UIFont.systemFont(ofSize: kCommentFontSize)]
                text.append(NSAttributedString(string:message, attributes: attrs))
            }
            
            if let time = value["time"] as? String {
                // time posted
                self.timeView?.text = Date(dateString: time, format: kDateFormat)
                    .shortTimeAgoSinceNow
            } else {
                self.timeView?.text = nil
            }
            
            if let profileImage = value["profile_image"] as? String, let photoUrl = URL(string:profileImage) {
                self.profileView?.sd_setImage(with: photoUrl, placeholderImage: placeholder, options: [], completed:
                { (image, error, type, url) in
                    DispatchQueue.main.async(execute: {
                        self.layoutSubviews()
                    })
                })
            } else {
                self.profileView?.image = placeholder
                DispatchQueue.main.async(execute: {
                    self.layoutSubviews()
                })
            }
            
            self.textView?.attributedText = text
            self.updateConstraints()
        } else {
            // error
            self.profileView?.image = nil
            self.textView?.attributedText = nil
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let profile = self.profileView {
            profile.layer.cornerRadius = profile.frame.width/2
        }
        
    }
    
}
