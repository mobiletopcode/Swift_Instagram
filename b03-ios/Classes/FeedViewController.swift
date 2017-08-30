//
//  FirstViewController.swift
//
//  Created by Bossly on 9/10/16.
//  Copyright © 2016 Bossly. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import SDWebImage
import AVFoundation
import DateToolsSwift
import MessageUI
import EVContactsPicker

class CustomUITabBar: UITabBar, UITabBarControllerDelegate {
    

    
   
    
    
    
    
    
    static let scrollToTopNotification = Notification.Name("CustomUITabBar.scrollToTop")

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if tabBarController.selectedViewController == viewController {
            // scroll to top
            NotificationCenter.default.post(name: CustomUITabBar.scrollToTopNotification, object: nil)
        }
        
        return true
    }

// TODO: uncomment if you wanna change tabbar height, default = 60
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let sizeThatFits = super.sizeThatFits(size)
        return CGSize(width: sizeThatFits.width, height: 40) // <- TabBar Height in px
    }
}

class FeedViewController: UITableViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, StoryTableViewCellDelegate, UISearchResultsUpdating, EVContactsPickerDelegate,MFMessageComposeViewControllerDelegate {
    /*!
     @method     messageComposeViewController:didFinishWithResult:
     @abstract   Delegate callback which is called upon user's completion of message composition.
     @discussion This delegate callback will be called when the user completes the message composition.
     How the user chose to complete this task will be given as one of the parameters to the
     callback.  Upon this call, the client should remove the view associated with the controller,
     typically by dismissing modally.
     @param      controller   The MFMessageComposeViewController instance which is returning the result.
     @param      result       MessageComposeResult indicating how the user chose to complete the composition process.
     */


    var itemsImage : Data? = nil
    var itemsString: String? = nil
    
    
    var searchController:UISearchController!
    let searchResultsController = UITableViewController()
    
    var posts:[FIRDataSnapshot] = []
    var searchResults:NSMutableArray = []
    var lastKey:FIRDataSnapshot?
    var stopPaginationLoading:Bool = false
    var collection = Story.recents

    var newRef:FIRDatabaseQuery?
    var oldRef:FIRDatabaseQuery?
    
    // used to show only one story
    var singleStoryId:String?
    var searchbarHidden:Bool = false
    var beginUpdate:Bool = true
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - View cycle

    override func viewDidLoad() {
        self.tableView.estimatedRowHeight = 350
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        
        if searchbarEnabled() {
            // add searchbar to find users to follow
            self.searchResultsController.tableView.dataSource = self
            self.searchResultsController.tableView.delegate = self
            
            self.searchController = UISearchController(searchResultsController:self.searchResultsController)
            self.searchController.searchResultsUpdater = self
            
            self.tableView.tableHeaderView = self.searchController.searchBar

            // show personal feed
            self.collection = User.current!.feed
        } else {
            self.tableView.tableHeaderView = nil
        }
        
        // show personal feed
        self.stopPaginationLoading = true
        self.posts = []
        
        if beginUpdate {
            self.loadData()
            self.tableView.reloadData()
        }
        
        if searchbarEnabled() {
            self.tableView.contentOffset = CGPoint(x:0,y:self.searchController.searchBar.frame.size.height)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTop),
                                               name: CustomUITabBar.scrollToTopNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: StoryTableViewCell.AutoplayMuteKey, object: nil)
        }

        NotificationCenter.default.removeObserver(self, name: CustomUITabBar.scrollToTopNotification, object: nil)
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let lastIndex = self.tableView.indexPathsForVisibleRows?.last {
            if lastIndex.section >= self.posts.count - 2 {
                loadMore()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let commentsCtrl = segue.destination as? CommentsTableViewController {
            let story = sender as? FIRDatabaseReference
            commentsCtrl.storyId = story?.key
        }

        if let profileCtrl = segue.destination as? ProfileFeedViewController {
            let user = sender as? FIRDatabaseReference
            profileCtrl.user = user
        }
    }
    
    // MARK: - Data
    func searchbarEnabled() -> Bool {
        return singleStoryId == nil && !searchbarHidden
    }
    
    func observeNewItems(_ firstKey:FIRDataSnapshot?) {
        // Listen for new posts in the Firebase database
        newRef?.removeAllObservers()
        newRef = self.collection.queryOrderedByKey()
        
        if let startKey = firstKey?.key {
            newRef = newRef?.queryStarting(atValue: startKey)
        }
        
        // Listen for new posts in the Firebase database
        newRef?.observe(.childAdded, with: { (snapshot) in
            if snapshot.key != firstKey?.key {
                DispatchQueue.main.async(execute: {
                    self.posts.insert(snapshot, at: 0)
                    self.tableView.reloadData()
                })
            }
        })
    }
    
    func loadData() {
        if let storyId = singleStoryId {
            let ref = Story.collection.child(storyId)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                DispatchQueue.main.async(execute: {
                    self.posts.insert(snapshot, at: 0)
                    self.stopPaginationLoading = true
                    print("Loaded \(snapshot.childrenCount) items")
                    
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                })
                
            }) { (error) in
                let alert = UIAlertController(title: kAlertErrorTitle, message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: kAlertErrorDefaultButton, style: .default) { (action) in })
                self.present(alert, animated: true) {}
            }
            
        } else {
            let ref = self.collection
                .queryOrderedByKey()
                .queryLimited(toLast: kPagination)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                DispatchQueue.main.async(execute: {
                    for item in snapshot.children {
                        self.posts.insert(item as! FIRDataSnapshot, at: 0)
                    }
                    
                    self.stopPaginationLoading = false
                    self.lastKey = snapshot.children.allObjects.first as? FIRDataSnapshot
                    
                    let firstKey = snapshot.children.allObjects.last as? FIRDataSnapshot
                    self.observeNewItems(firstKey)
                    
                    print("Loaded \(snapshot.childrenCount) items")
                    
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                })
                
            }) { (error) in
                let alert = UIAlertController(title: kAlertErrorTitle, message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: kAlertErrorDefaultButton, style: .default) { (action) in })
                self.present(alert, animated: true) {}
            }
            
            // track for remove
            oldRef?.removeAllObservers()
            oldRef = self.collection
            oldRef?.observe(.childRemoved, with: { (snapshot) in
                DispatchQueue.main.async(execute: {
                    for item in self.posts {
                        if snapshot.key == item.key {
                            // remove item from collection
                            self.posts.remove(at: self.posts.index(of: item)!)
                        }
                    }
                    
                    self.tableView.reloadData()
                })
            })
        }
    }
    
    func loadMore() {
        // load more
        if self.stopPaginationLoading == true || singleStoryId != nil {
            return
        }
        
        var refPagination = self.collection.queryOrderedByKey().queryLimited(toLast: kPagination + 1)
        
        if let last = self.lastKey {
            refPagination = refPagination.queryEnding(atValue: last.key)
            
            // load rest feed
            refPagination.observeSingleEvent(of: .value, with: { (snapshot) -> Void in
                
                print("Loaded more \(snapshot.childrenCount) items")

                let items = snapshot.children.allObjects
                
                if items.count > 1 {
                    for i in 2...items.count {
                        let data = items[items.count-i] as! FIRDataSnapshot
                        self.posts.append(data)
                    }
                    
                    self.lastKey = items.first as? FIRDataSnapshot
                    self.tableView.reloadData()
                } else {
                    self.stopPaginationLoading = true
                    print("last item")
                }
            })
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        User.collection.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            
            let results:NSMutableArray = []
            
            for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
                if let value = child.value as? [String:Any], let name = value["name"] as? String {
                    if name.lowercased().contains(searchController.searchBar.text!.lowercased()) {
                        results.add(User(child))
                    }
                }
            }
            
            self.searchResults = results
            self.searchResultsController.tableView.reloadData()
        })
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // reset states
        self.lastKey = nil
        self.stopPaginationLoading = true
        self.posts = []
        
        // reload data
        loadData()
    }
    
    func scrollToTop(notification:NSNotification) {
        if self.posts.count > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    // MARK: - TableView Delegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView {
            return self.posts.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return 1
        } else {
            return self.searchResults.count
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == self.tableView {
            let view = tableView.dequeueReusableCell(withIdentifier: "Profile") as? UserTableViewCell
            let snap = self.posts[section]

            view?.cellIndex = section
            view?.linkedStoryRef = Story(snap.key).ref
            
            if let key = snap.value as? String {
                view?.userRef = User(key).ref
            } else {
                // compatibility with version 1.4 and less
                let story = Story(snap.key)
                story.fetchInBackground(completed: { (model, success) in
                    if success {
                        view?.userRef = story.userRef
                    }
                })
            }
            
            view?.delegate = self
            return view
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.tableView {
            return 45
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            if kAutoplayVideo {
                if let storyCell = cell as? StoryTableViewCell {
                    storyCell.playerLayer?.player?.play()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            if let storyCell = cell as? StoryTableViewCell {
                storyCell.playerLayer?.player?.pause()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            let identifier = "Cell"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! StoryTableViewCell

            let snap = self.posts[indexPath.section]
            
            cell.ref = snap.ref
            cell.storyRef = Story(snap.key).ref
            cell.delegate = self
            cell.cellIndex = indexPath.section
            
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "User") as! UserTableViewCell

            if let userInfo = self.searchResults[indexPath.row] as? User {
                cell.userRef = userInfo.ref
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            // ..
        } else {
            // start follow
            if let selectedUser = self.searchResults[indexPath.row] as? User {

                if selectedUser.isFollow {
                    selectedUser.unfollow()
                } else {
                    selectedUser.follow()
                }
                
                // refresh cell
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    
    // MARK: - Show Contacts
    
    
    func showContact(){
        let contactPicker = EVContactsPickerViewController()
        contactPicker.delegate = self as? EVContactsPickerDelegate
        self.navigationController?.pushViewController(contactPicker, animated: true)
        
        
        
    }
    
    func didChooseContacts(_ contacts: [EVContactProtocol]?) {
        var conlist = [String] ()
        if let cons = contacts {
            for con in cons {
                if (con.phone) != nil {
//                    conlist += fullname + "\n"
                    conlist.append(con.phone!)
                    
                }
            }
            //            self.textView?.text = conlist
            
            self.showMessageController(list: conlist)
            
        } else {
            print("I got nothing")
        }
               let _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    
    func showMessageController(list: [String]) {
        
        
        if MFMessageComposeViewController.canSendText() {
            let composeVC = MFMessageComposeViewController()
            composeVC.messageComposeDelegate = self as MFMessageComposeViewControllerDelegate
            // Configure the fields of the interface.
            composeVC.recipients = list
            // Present the view controller modally.
            if itemsImage != nil {
                composeVC.addAttachmentData(itemsImage!, typeIdentifier: "kUTTypePNG", filename: "image.png")
                
            }
            
            if itemsString != nil {
                composeVC.body = itemsString
                
            }
            
            
            self.present(composeVC, animated: true, completion: nil)
            
        }
       
        
        //self.itemsMSG
        
        
    }
        // MARK: - Message composer
    
    
    
    @available(iOS 4.0, *)
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        
        
        
    }
    
    
    // MARK: - Cell delegate
    
    func storyAction(_ data: FIRDatabaseReference?) {
        if let story = data {
            Like.story(story)
        }
    }
    
    func storyDidLike(_ data: FIRDatabaseReference?) {
        if let story = data {
            Like.toggle(story)
        }
    }
    
    func storyDidShare(_ data: FIRDatabaseReference?) {
        
        if let ref = data {
            let story = Story(ref.key)
            
            story.fetchInBackground(completed: { (model, success) in
                
                // try to get image first
                var items:[Any] = []
                
                if story.videoUrl != nil {
                    items.append(story.videoUrl)
                } else if let imageManager = SDWebImageManager.shared(), let imageCache = SDImageCache.shared() {
                    let imageURL:URL = URL(string:story.media)!
                    
                    if imageManager.cachedImageExists(for: imageURL) {
                        let cachedKey = imageManager.cacheKey(for: imageURL)
                        if let image = imageCache.imageFromDiskCache(forKey: cachedKey) {
                            items.append(image)
                        }
                    } else {
                        items.append(imageURL)
                    }
                }
                
                let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo,UIActivityType.postToFacebook]
                self.present(activityViewController, animated: true) {
                    // ..
                }
                
            })
        }
    }
    
    func storyDidComment(_ data: FIRDatabaseReference?) {
        self.performSegue(withIdentifier: "feed.comments", sender: data)
    }
    
    /* UserTableViewCellDelegate */
    func onStoryRemoved() {
        if let _ = singleStoryId {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func storyMenu(_ story: FIRDatabaseReference?, position:NSInteger) {
        let menuController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let postedStory = Story(self.posts[position].key)
        
        
      
        
        
        
        postedStory.fetchInBackground { (model, success) in
            
            // delete for own stories
            if User(postedStory.userId).isCurrent() {
                let removeAction = UIAlertAction(title: "Remove the story", style: .destructive) { (action) in
                    // remove from my feed
                    let snap = self.posts[position]
                    Story.removeStory(snap.ref.key)
                    self.onStoryRemoved()
                }
                menuController.addAction(removeAction)
                
                let contactAction = UIAlertAction(title: "Contacts", style: .destructive) { (action) in
                    // remove from my feed
                    
                    let snap = self.posts[position]
                    
                    
                        let story = Story(snap.ref.key)
                        
                        story.fetchInBackground(completed: { (model, success) in
                            
                            // try to get image first
//                            var items:[Any] = []
                            
                            if story.videoUrl != nil {
//                                self.itemsMSG.append(story.videoUrl)
                                self.itemsString = story.videoUrl.absoluteString
                                
                            } else if let imageManager = SDWebImageManager.shared(), let imageCache = SDImageCache.shared() {
                                let imageURL:URL = URL(string:story.media)!
                                
                                if imageManager.cachedImageExists(for: imageURL) {
                                    let cachedKey = imageManager.cacheKey(for: imageURL)
                                    if let image = imageCache.imageFromDiskCache(forKey: cachedKey) {
//                                        self.itemsMSG.append(image)
                                        self.itemsImage = UIImageJPEGRepresentation(image, 0.5)
                                    }
                                } else {
//                                    self.itemsMSG.append(imageURL)
                                    self.itemsString = imageURL.absoluteString
                                }
                            }
                        })
                    
                    
                    
                    
                    
                    
                    self.showContact()
                }
                menuController.addAction(contactAction)
                
                
                
                
            }
            // hide or report for others
            else {
                let reportAction = UIAlertAction(title: "Report", style: .destructive) { (action) in
                    // 1. remove from my feed
                    let snap = self.posts[position]
                    snap.ref.removeAllObservers()
                    snap.ref.removeValue()
                    
                    let body = "Please remove the story with id: \(snap.key), as not appropriate."
                    
                    // 2. send email with report
                    if (MFMailComposeViewController.canSendMail()) {
                        let email = MFMailComposeViewController()
                        email.setSubject("Report a content")
                        email.setMessageBody(body, isHTML: false)
                        email.mailComposeDelegate = self as! MFMailComposeViewControllerDelegate
                        email.setToRecipients([kReportEmail])
                        self.present(email, animated: true, completion: nil)
                    } else {
                        let encodedBody = body.addingPercentEncoding(withAllowedCharacters:.urlHostAllowed) ?? ""
                        
                        if let mailurl = URL(string:"mailto:\(kReportEmail)?subject=\(encodedBody)") {
                            UIApplication.shared.openURL(mailurl)
                        }
                        
                        self.onStoryRemoved()
                    }
                }
                
                menuController.addAction(reportAction)
                
                let hideAction = UIAlertAction(title: "Hide the story", style: .default) { (action) in
                    // remove from my feed
                    let snap = self.posts[position]
                    snap.ref.removeAllObservers()
                    snap.ref.removeValue()
                    self.onStoryRemoved()
                }
                menuController.addAction(hideAction)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            menuController.addAction(cancelAction)
            
            self.present(menuController, animated: true)
        }

    }
}

extension FeedViewController : MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        self.onStoryRemoved()
    }
}

extension FeedViewController : UserTableViewCellDelegate {
    func didSelected(userRef: FIRDatabaseReference) {
        self.performSegue(withIdentifier: "show.profile", sender: userRef)
    }

    func didAction(storyRef: FIRDatabaseReference, position:NSInteger) {
        storyMenu(storyRef, position: position)
    }
}


