//
//  UpdateProfileViewController.swift
//  Drop
//
//  Created by Aashna Garg on 5/19/16.
//  Copyright © 2016 Aashna Garg. All rights reserved.
//

import UIKit
import QuartzCore
import CloudKit
import Parse


protocol UpdateProfileViewControllerDelegate {
    func didSaveProfile(ProfileRecord: CKRecord, wasEditingProfile: Bool)
}


class UpdateProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var txtProfileTitle: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    
    
    //    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var btnSelectPhoto: UIButton!
    
    @IBOutlet weak var btnRemoveImage: UIButton!
    
    @IBOutlet weak var viewWait: UIView!
    
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var phoneNumber: UITextField!
    
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var dateOfBirth: UIDatePicker!
    
    
    var delegate: UpdateProfileViewControllerDelegate!
    
    var imageURL: NSURL!
    
    let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    
    let tempImageName = "temp_image.jpg"
    
    var editedProfileRecord: CKRecord!
    
    var email = ""
    
    var spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        btnRemoveImage.hidden = true
        viewWait.hidden = true
        
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(UpdateProfileViewController.handleSwipeDownGestureRecognizer(_:)))
        swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        view.addGestureRecognizer(swipeDownGestureRecognizer)
        
        
        if let editedProfile = editedProfileRecord {
            txtProfileTitle.text = editedProfile.valueForKey("ProfileTitle") as? String
            //     textView.text = editedProfile.valueForKey("ProfileText") as! String
            let imageAsset: CKAsset = editedProfile.valueForKey("ProfileImage") as! CKAsset
            imageView.image = UIImage(contentsOfFile: imageAsset.fileURL.path!)
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            
            imageURL = imageAsset.fileURL
            btnRemoveImage.hidden = false
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if(imageView.accessibilityIdentifier == "mystery-man") {
            btnRemoveImage.hidden = true
        } else {
            btnRemoveImage.hidden = false
        }
        btnSelectPhoto.layer.cornerRadius = 5.0
        btnRemoveImage.layer.cornerRadius = btnRemoveImage.frame.size.width/2
        
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        userEmail.text = email
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    // MARK: IBAction method implementation
    
    @IBAction func pickPhoto(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.allowsEditing = false
            
            presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func unsetImage(sender: AnyObject) {
        imageView.image = UIImage(named: "user.png")
        imageView.accessibilityIdentifier = "mystery-man"
        btnRemoveImage.hidden = true
        imageURL = nil
    }
    
    @IBAction func saveProfile(sender: AnyObject) {
        if txtProfileTitle.text == "" {//|| textView.text == "" {
            return
        }
        
        
        spinner.startAnimating()
        
        viewWait.hidden = false
        view.bringSubviewToFront(viewWait)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
//        var ProfileRecord: CKRecord!
//        var isEditingProfile: Bool!
//        
//        if let editedProfile = editedProfileRecord {
//            ProfileRecord = editedProfile
//            isEditingProfile = true
//        }
//        else {
//            let timestampAsString = String(format: "%f", NSDate.timeIntervalSinceReferenceDate())
//            let timestampParts = timestampAsString.componentsSeparatedByString(".")
//            let ProfileID = CKRecordID(recordName: timestampParts[0])
//            
//            ProfileRecord = CKRecord(recordType: "Profiles", recordID: ProfileID)
//            
//            isEditingProfile = false
//        }
//        
//        ProfileRecord.setObject(txtProfileTitle.text, forKey: "ProfileTitle")
//        //     ProfileRecord.setObject(textView.text, forKey: "ProfileText")
//        ProfileRecord.setObject(NSDate(), forKey: "ProfileEditedDate")
//        
//        if let url = imageURL {
//            let imageAsset = CKAsset(fileURL: url)
//            ProfileRecord.setObject(imageAsset, forKey: "ProfileImage")
//        }
//        else {
//            let fileURL = NSBundle.mainBundle().URLForResource("user", withExtension: "png")
//            let imageAsset = CKAsset(fileURL: fileURL!)
//            ProfileRecord.setObject(imageAsset, forKey: "ProfileImage")
//        }
        
        //        let container = CKContainer.defaultContainer()
        //        let privateDatabase = container.privateCloudDatabase
        //
        //        privateDatabase.saveRecord(ProfileRecord, completionHandler: { (record, error) -> Void in
        //            if (error != nil) {
        //                print(error)
        //            }
        //            else {
        //                self.delegate.didSaveProfile(ProfileRecord, wasEditingProfile: isEditingProfile)
        //            }
        //
        //            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        //                self.viewWait.hidden = true
        //                self.navigationController?.setNavigationBarHidden(false, animated: true)
        //            })
        //        })
        let newUser = PFUser()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle

        newUser.email = userEmail.text
        newUser.username = userName.text
        newUser.password = userPassword.text
        newUser["phone"] = phoneNumber.text
        newUser["dob"] = dateFormatter.stringFromDate(dateOfBirth.date)
        
        if(userName.text?.characters.count < 5) {
            let alert = UIAlertView(title: "Invalid", message: "Username must be greater than 5 characters", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
        } else if(userPassword.text?.characters.count < 8) {
            let alert = UIAlertView(title: "Invalid", message: "Password must be greater than 8 characters", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
        }
        else if(userPassword.text == confirmPassword.text) == false {
            let alert = UIAlertView(title: "Invalid", message: "Passwords must match !", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
        }
        else {
        newUser.signUpInBackgroundWithBlock({ (succeed, error) -> Void in
            
            // Stop the spinner
            self.spinner.stopAnimating()
            if ((error) != nil) {
                let alert = UIAlertView(title: "Error", message: "\(error)", delegate: self, cancelButtonTitle: "OK")
                alert.show()
                
            } else {
                let alert = UIAlertView(title: "Success", message: "Signed Up", delegate: self, cancelButtonTitle: "OK")
                alert.show()
                self.performSegueWithIdentifier("mainVIew", sender: self)
            }
        })
      }
    }
    
    
    @IBAction func dismiss(sender: AnyObject) {
        if let url = imageURL {
            let fileManager = NSFileManager()
            if fileManager.fileExistsAtPath(url.absoluteString) {
                do {
                    try fileManager.removeItemAtURL(url)
                } catch _ {
                }
            }
        }
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: Custom method implementation
    
    func handleSwipeDownGestureRecognizer(swipeGestureRecognizer: UISwipeGestureRecognizer) {
        txtProfileTitle.resignFirstResponder()
        //      textView.resignFirstResponder()
    }
    
    
    func saveImageLocally() {
        imageView.accessibilityIdentifier = "image"
        let imageData: NSData = UIImageJPEGRepresentation(imageView.image!, 0.8)!
        let path = documentsDirectoryPath.stringByAppendingPathComponent(tempImageName)
        imageURL = NSURL(fileURLWithPath: path)
        imageData.writeToURL(imageURL, atomically: true)
    }
    
    
    // MARK: UIImagePickerControllerDelegate method implementation
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        saveImageLocally()
        
        dismissViewControllerAnimated(true, completion: nil)
        btnRemoveImage.hidden = false
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

