//
//  CreateViewController.swift
//  b03-ios
//
//  Created by Bossly on 9/12/16.
//  Copyright © 2016 Bossly. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import MobileCoreServices
import GBHFacebookImagePicker

class CreateViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,GBHFacebookImagePickerDelegate {
   


    @IBOutlet weak var progressView:UIProgressView?
    @IBOutlet weak var progressLabel:UILabel?
    
    var isPresented:Bool = false
    var previousTab:Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("Add Image Picker Here...")
        
        if !self.isPresented {
            self.isPresented = true
          self.showImagePickingOptions()
        }
        
    }
    
    func getMedia(picker : UIImagePickerController, info: [String:Any]) {
    
    
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var thumbnail:NSData?
        var media:NSData?
        var type:String = ".jpg"
        
        if "public.movie".compare(info[UIImagePickerControllerMediaType] as! String).rawValue == 0 {
            // for movie
            let video = info[UIImagePickerControllerMediaURL] as! URL
            let videoReference = info[UIImagePickerControllerReferenceURL] as! URL
            
            media = NSData(contentsOf: video)!
            type = ".mov"
            
            // generate thumbnail
            let asset = AVAsset(url: videoReference)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            var time = asset.duration
            //If possible - take not the first frame (it could be completely black or white on camara's videos)
            time.value = min(time.value, 2)
            
            if let imageRef = try? imageGenerator.copyCGImage(at: time, actualTime: nil) {
                let image = UIImage(cgImage: imageRef)
                thumbnail = UIImageJPEGRepresentation(image, kJPEGImageQuality) as NSData?
            }
        } else {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            thumbnail = UIImageJPEGRepresentation(image, kJPEGImageQuality) as NSData?
        }

        if let data = thumbnail {
            self.progressView?.isHidden = false
            self.progressLabel?.isHidden = false

            // Data in memory
            let storage = FIRStorage.storage().reference()
        
            // hide picker and show uploading process
            picker.dismiss(animated: true, completion: {})
            
            if let user = FIRAuth.auth()?.currentUser {
                
                let imgref = storage.child("\(user.uid)-\(NSDate().timeIntervalSince1970).jpg")
                let metadata = FIRStorageMetadata(dictionary: [ "contentType" : "image/jpg"])
                
                // Upload the file to the path "media/"
                let uploadTask = imgref.put(data as Data, metadata: metadata) { metadata, error in
                    if (error != nil) {
                        // Uh-oh, an error occurred!
                        let alert = UIAlertController(title: kAlertErrorTitle, message: "Can't upload now. Please try later", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: kAlertErrorDefaultButton, style: .default) { (action) in })
                        self.present(alert, animated: true) {}
                        self.tabBarController?.selectedIndex = 0 // home
                        self.isPresented = false
                    } else {
                        
                        // Metadata contains file metadata such as size, content-type, and download URL.
                        let url = metadata!.downloadURL()!.absoluteString
                        
                        if let video = media {
                            
                            let videoref = storage.child("\(user.uid)-\(NSDate().timeIntervalSince1970)\(type)")
                            let videoMeta = FIRStorageMetadata(dictionary: [ "contentType" : "video/quicktime"])
                            videoref.put(video as Data, metadata: videoMeta) { metadata, error in
                                let videourl = metadata!.downloadURL()!.absoluteString
                                Story.createStory(user, url: url, video:videourl)
                            }
                            
                            self.progressView?.isHidden = true
                            self.progressLabel?.text = kMessageUploadingDone
                            
                            self.dismiss(animated: false, completion: nil)
                            self.tabBarController?.selectedIndex = 0 // home
                            self.isPresented = false
                            
                            
                        } else {
                            
                           self.applyImageFilter(user: user, imageUrl: url) // By RMN
                         
                        }

                        
                    }
                }
                
                uploadTask.observe(.progress) { snapshot in
                    // A progress event occurred
                    if let progress = snapshot.progress {
                        let complete = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                        let percentComplete = Int(complete * 98) + 1 // never show 0% or 100%
                        self.progressView?.progress = Float(complete)
                        self.progressLabel?.text = "\(kMessageUploadingProcess): \(percentComplete)%"
                    }
                }
            }
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: {
            self.tabBarController?.selectedIndex = 0 // home
            self.isPresented = false
        })
    }
    
    func applyImageFilter(user: FIRUser,  imageUrl: String){  // By RMN
        
        let fileName = "\(NSDate().timeIntervalSince1970).jpg";
        
     //TODO: For now i have hardcoded some parameters as i am not sure what parameters needs to be dynamic
        MTWebService.sharedService.getFilteredImage(fbUId: "4", appId: "4", objectId: "44", filter: "gan_vogh", filterFileName: fileName, srcImageUrl: imageUrl, s3FileName: "testiosswift", block: { (data, error) in
            
            if error != nil{
                Story.createStory(user, url: imageUrl, video:"")
            }else{
                
                //{savePaths=["s3:\/\/portraitdeep\/gan_vogh.jpg"]} = http://portraitdeep.s3.amazonaws.com/gan_vogh.jpg
                //TODO: Above is not valid JSON so i have to apply manually processing of string. So once its corrected over server we should correct over here as well.
                // Have to do error handling as well in case process doesn't work.
                
                if let newImageUrl = data as? String{
                    
                    print(newImageUrl)
                    var finalNewImgUrl = newImageUrl.replacingOccurrences(of: "{savePaths=[\"", with: "")
                    finalNewImgUrl = finalNewImgUrl.replacingOccurrences(of: "\"]}", with: "")
                    finalNewImgUrl = finalNewImgUrl.replacingOccurrences(of: ":", with: "")
                    
                    
                    let strComponents:[String] = finalNewImgUrl.components(separatedBy: "\\/")
                    
                    if strComponents.count == 4{
                        finalNewImgUrl = "https://"+strComponents[2]+"."+strComponents[0]+".amazonaws.com/"+strComponents[3]
                        print(finalNewImgUrl)
                        Story.createStory(user, url: finalNewImgUrl, video:"")
                        
                    }else{
                        Story.createStory(user, url: imageUrl, video:"")
                    }
                    
                    
                    
                    
                }else{
                   Story.createStory(user, url: imageUrl, video:"")
                }
                
            }
            
            
            
            self.progressView?.isHidden = true
            self.progressLabel?.text = kMessageUploadingDone
            
            self.dismiss(animated: false, completion: nil)
            self.tabBarController?.selectedIndex = 0 // home
            self.isPresented = false
            
            
        })
        
    }
    
    // New Code CHINNU 14/08/17
    
    func showImagePickingOptions() {
    
        let actionSheet = UIAlertController(title: "Choose Image !!", message: "Please select an option to choose image", preferredStyle: .actionSheet)
        
        let galleryOption = UIAlertAction(title: "Gallery", style: .default, handler: {(action: UIAlertAction!) in
        
            print("Gallery Option selected")
            
                self.progressView?.isHidden = true
                self.progressLabel?.isHidden = true
                
                let picker:UIImagePickerController = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
        
        })
        
        let fbOption = UIAlertAction(title: "Facebook", style: .default, handler: {(action: UIAlertAction!) in
            
            print("fb Option selected")
            
            let picker = GBHFacebookImagePicker()

            picker.presentFacebookAlbumImagePicker(from: self, delegate: self)
            
        })
        
        let cancelOption = UIAlertAction(title: "Cancel", style:.destructive, handler: {(action: UIAlertAction!) in
            
            print("cancel Option selected")
            self.gotoHomeScreen()
            
        })
        
        actionSheet.addAction(galleryOption)
        actionSheet.addAction(fbOption)
        actionSheet.addAction(cancelOption)
       // actionSheet.addAction(cancelOption)
        
        self.present(actionSheet, animated: true, completion: nil)
    
    }
    
    
    // added on 14/08/17
    func getImageFromFb(image: UIImage){
        
        
        //let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let thumbnail = UIImageJPEGRepresentation(image, kJPEGImageQuality) as NSData?
        
        if let data = thumbnail {
            self.progressView?.isHidden = false
            self.progressLabel?.isHidden = false
            
            // Data in memory
            let storage = FIRStorage.storage().reference()
            
            if let user = FIRAuth.auth()?.currentUser {
                
                let imgref = storage.child("\(user.uid)-\(NSDate().timeIntervalSince1970).jpg")
                let metadata = FIRStorageMetadata(dictionary: [ "contentType" : "image/jpg"])
                
                // Upload the file to the path "media/"
                let uploadTask = imgref.put(data as Data, metadata: metadata) { metadata, error in
                    if (error != nil) {
                        // Uh-oh, an error occurred!
                        let alert = UIAlertController(title: kAlertErrorTitle, message: "Can't upload now. Please try later", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: kAlertErrorDefaultButton, style: .default) { (action) in })
                        self.present(alert, animated: true) {}
                        self.tabBarController?.selectedIndex = 0 // home
                        self.isPresented = false
                    } else {
                        
                        // Metadata contains file metadata such as size, content-type, and download URL.
                        let url = metadata!.downloadURL()!.absoluteString
                        
                       self.applyImageFilter(user: user, imageUrl: url) // By RMN
                        
                    }
                }
                
                uploadTask.observe(.progress) { snapshot in
                    // A progress event occurred
                    if let progress = snapshot.progress {
                        let complete = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                        let percentComplete = Int(complete * 98) + 1 // never show 0% or 100%
                        self.progressView?.progress = Float(complete)
                        self.progressLabel?.text = "\(kMessageUploadingProcess): \(percentComplete)%"
                    }
                }
            }
            
        }
        
        
        
    }
    

    
    func gotoHomeScreen() {
    
        self.tabBarController?.selectedIndex = 0 // home
        self.isPresented = false
    
    }
    
    // MARK: - GBHFacebookImagePicker Protocol
    
    func facebookImagePicker(imagePicker: UIViewController, didFailWithError error: Error?) {
        print("Cancelled Facebook Album picker with error")
        print(error.debugDescription)
        
        gotoHomeScreen()
    }
    
    // Optional
    func facebookImagePicker(didCancelled imagePicker: UIViewController) {
        print("Cancelled Facebook Album picker")
        
       gotoHomeScreen()
    }

    func facebookImagePicker(imagePicker: UIViewController, imageModel: GBHFacebookImage) {
        
        self.getImageFromFb(image: imageModel.image!)
        
    }

}
