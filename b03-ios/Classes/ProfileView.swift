//
//  ProfileView.swift
//  Project
//
//  Created by Bossly on 10/10/16.
//  Copyright © 2016 Bossly. All rights reserved.
//

import UIKit

class ProfileView: UIImageView {
    
    // MARK: - Overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners()
    }
    
    // MARK: - Helper methods
    
    func setupView() {
        
        // default placeholder
        self.image = UIImage(named: "avatarPlaceholder")

        // set borders
        self.clipsToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(white: 0.1, alpha: 0.1).cgColor

        // SDWebImage config
        self.setIndicatorStyle(.gray)
        self.setShowActivityIndicator(true)
    }
    
    func roundCorners() {
        self.layer.cornerRadius = self.frame.width/2
    }
}

class RoundButton: UIButton {
    // MARK: - Overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners()
    }
    
    // MARK: - Helper methods
    
    func setupView() {
        
        // set borders
        self.clipsToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(white: 0.1, alpha: 0.3).cgColor
    }
    
    func roundCorners() {
        self.layer.cornerRadius = self.frame.height/6
    }
}
