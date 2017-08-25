//
//  EditProfileViewController.swift
//  Project
//
//  Created by Bossly on 10/12/16.
//  Copyright © 2016 Bossly. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileView:UITextField?
    @IBOutlet weak var profileImage:ProfileView?
    @IBOutlet weak var uploadActivity:UIActivityIndicatorView?
    
    var user:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser = User.current {
            self.user = currentUser
            
            if let _user = self.user {
                _user.fetchInBackground(completed: { (model, success) in
                    self.profileView?.text = _user.name
                    self.profileImage?.sd_setImage(with: URL(string:_user.photo))
                })
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.user?.name = self.profileView?.text ?? kDefaultUsername
        self.user?.saveData()
    }
    
    @IBAction func changePhoto(_ sender:Any) {
        let picker:UIImagePickerController = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            picker.dismiss(animated: true, completion: {
                self.profileImage?.image = nil
                self.uploadActivity?.startAnimating()

                // resize image
                let newSize = CGSize(width:kProfilePhotoSize, height:kProfilePhotoSize)
                UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
                image.draw(in: CGRect(x:0, y:0, width:newSize.width, height:newSize.height))
                let smallImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                
                self.upload(photo: smallImage, with: { (success) in
                    self.profileImage?.image = image
                    self.uploadActivity?.stopAnimating()
                })
            })
        }
    }
    
    func upload(photo:UIImage, with complete:@escaping (Bool) -> Void) {
        
        let storage = FIRStorage.storage().reference()
        let data: Data? = UIImageJPEGRepresentation(photo, kJPEGImageQuality)
        
        guard let userkey = user?.ref.key else {
            return
        }
        
        let imgref = storage.child("\(userkey)-\(NSDate().timeIntervalSince1970).jpg")
        
        // Upload the file to the path "images/"
        imgref.put(data!, metadata: nil) { metadata, error in
            if (error != nil) {
                // Uh-oh, an error occurred!
                let alert = UIAlertController(title: kAlertErrorTitle,
                                              message: "Can't upload now. Please try later", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: kAlertErrorDefaultButton, style: .default) { (action) in })
                self.present(alert, animated: true) {}
                complete(false)
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                self.user?.photo = metadata!.downloadURL()!.absoluteString
                self.user?.saveData()
                complete(true)
            }
        }
    }
}
