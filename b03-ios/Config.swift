//
//  Config.swift
//
//  Created by Bossly on 9/14/16.
//  Copyright © 2016 Bossly. All rights reserved.
//
//  Parameters format: (don't change the key name)
//  key:type = value

import UIKit
import AVFoundation

// MARK: REQUIRED
/* Configure AdMob here by changing value. Please don't change the key */

let kAdMobEnabled = false

// TODO: replace id's with you own if you want to show Ad
let kAdMobApplicationID = "ca-app-pub-3940256099942544~1458002511"
let kAdMobUnitID = "ca-app-pub-3940256099942544/2934735716"

/*
 EULA url. Required for publishing.
 */
let kEulaUrl = "<your EULA(Terms of Usage) url here>"
let kReportEmail = "<your email here>"

// MARK: Configs

/*
 The video is allowed in feed, but it shows a video player (if the first picture is black 
 you will see black. Please use the autoplay (true) to play video on scrolling. The video will 
 be streamed from server (not downloaded) so it used less network while scrolling.
 */
let kAutoplayVideo = true

/*
 Scale of video, you can choose one of these recommended:
    AVLayerVideoGravityResizeAspectFill - resize to fill the square
    AVLayerVideoGravityResizeAspect - resize to fit the square
 */
let kVideoScale = AVLayerVideoGravityResizeAspectFill

let kJPEGImageQuality:CGFloat = 0.4 // between 0..1
let kPagination:UInt = 1000
let kMaxConcurrentImageDownloads = 2 // the count of images donloading at the same time

let kLikeTapCount = 2 // you can like the photo by double tap on. number of taps
let kLikeTapAnimationDuration:TimeInterval = 0.3 // seconds
let kLikeTapAnimationScale:CGFloat = 3.0 // the max scale of heart to animate in seconds

let kPhotoShadowRadius:CGFloat = 10.0 // all photos has inner shadow on top and bottom
let kPhotoShadowColor:UIColor = UIColor(white: 0, alpha: 0.1)
let kProfilePhotoSize:CGFloat = 100 // px

let kCommentFontSize:CGFloat = 13.0 // points
let kFavoritesColumns:CGFloat = 3
let kDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"

// MARK: Database
/*
 Change this values to set another firebase key path.
 Must be a non-empty string and not contain '.' '#' '$' '[' or ']'
 */

let kUserFeedKey = "user_feed"
let kUsersKey = "users"
let kTokensKey = "tokens"
let kUploadsKey = "uploads"
let kFollowersKey = "followers"
let kFollowinsKey = "followings"
let kDataRecentsKey = "recents"
let kDataPostKey = "posts"
let kDataCommentKey = "comments"
let kDataLikeKey = "likes"
let kDataFavoritesKey = "activity"

// MARK: Strings
/*
 Localized text displayed to User
 */

let kDefaultUsername = NSLocalizedString("Mr. Mustage", comment: "Text used when username not set")
let kDefaultProfilePhoto = "" // url to default photo. will be stored in database

let kAlertErrorTitle = NSLocalizedString("Error", comment:"")
let kAlertErrorDefaultButton = NSLocalizedString("OK", comment:"")

let kMessageUploadingDone = NSLocalizedString("Done!", comment:"")
// example: Uploading: 12% (percentage will be added)
let kMessageUploadingProcess = NSLocalizedString("Uploading", comment:"")
