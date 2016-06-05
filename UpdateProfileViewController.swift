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

extension UIView {
    func addBackgroundtoSignUp() {
        
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRectMake(0, 0, width, height))
        imageViewBackground.image = UIImage(named: "drop-sign-up-screen.png")
        // you can change the content mode:
        imageViewBackground.contentMode = UIViewContentMode.ScaleAspectFill
        
        self.addSubview(imageViewBackground)
        self.sendSubviewToBack(imageViewBackground)
    }}


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
        self.view.addBackgroundtoSignUp()
        //   self.view.backgroundColor = UIColor(patternImage: UIImage(named: "drop-sign-up-screen.png")!)
        
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
    
    
    // MARK: IBAction method implementation
    
    @IBAction func pickPhoto(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.allowsEditing = false
            
            presentViewController(imagePicker, animated: true, completion: nil)
        }
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            imagePicker.allowsEditing = false
            imagePicker.cameraCaptureMode = .Photo
            imagePicker.modalPresentationStyle = .FullScreen
            presentViewController(imagePicker,
                                  animated: true,
                                  completion: nil)
        }
    }
    
    @IBAction func unsetImage(sender: AnyObject) {
        imageView.image = UIImage(named: "user.png")
        imageView.accessibilityIdentifier = "mystery-man"
        btnRemoveImage.hidden = true
        imageURL = nil
    }
    
    /* referred from http://www.appcoda.com/login-signup-parse-swift/ */
    
    @IBAction func saveProfile(sender: AnyObject) {
        if txtProfileTitle.text == "" {//|| textView.text == "" {
            return
        }
        
        
        spinner.startAnimating()
        
        viewWait.hidden = false
        view.bringSubviewToFront(viewWait)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        if(userName.text?.characters.count < 5) {
            
            let alert = UIAlertController(title: "Invalid", message:"Username must be greater than 5 characters", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
            //            let alert = UIAlertView(title: "Invalid", message: "Username must be greater than 5 characters", delegate: self, cancelButtonTitle: "OK")
            //  alert.show()
            
        } else if(userPassword.text?.characters.count < 8) {
            let alert = UIAlertController(title: "Invalid", message:"Password must be greater than 8 characters", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
            // alert.show()
            
        }
        else if(userPassword.text == confirmPassword.text) == false {
            let alert = UIAlertController(title: "Invalid", message:"Passwords must match", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
        }
        else {
            let newUser = PFUser()
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            newUser["dob"] = dateFormatter.stringFromDate(dateOfBirth.date)
            
            newUser.email = userEmail.text
            newUser.username = userName.text
            newUser.password = userPassword.text
            newUser["phone"] = phoneNumber.text
            newUser.signUpInBackgroundWithBlock({ (succeed, error) -> Void in
                
                // Stop the spinner
                self.spinner.stopAnimating()
                if ((error) != nil) {
                    let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
                    self.presentViewController(alert, animated: true){}
                    
                } else {
                    let alert = UIAlertController(title: "Success", message: "Signed Up", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
                    self.presentViewController(alert, animated: true){}
                    AppDelegate.getAppDelegate().loaded = false
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
    
    func saveImageInDatabase() {
        
        if imageView.image == nil {
            //image is not included alert user
            print("Image not uploaded")
        }else {
            // let newUser = PFUser.currentUser()
            
            let profilePic = PFObject(className: "Profile_Image")
            //posts["imageText"] = imageText
            profilePic["uploader"] = PFUser.currentUser()
            profilePic.saveInBackgroundWithBlock({
                (success: Bool, error: NSError?) -> Void in
                
                if error == nil {
                    /**success saving, Now save image.***/
                    
                    //create an image data
                    let imageData = UIImagePNGRepresentation(self.imageView.image!)
                    //create a parse file to store in cloud
                    let parseImageFile = PFFile(name: "uploaded_image.png", data: imageData!)
                    profilePic["imageFile"] = parseImageFile
                    profilePic.saveInBackgroundWithBlock({
                        (success: Bool, error: NSError?) -> Void in
                        
                        if error == nil {
                            //take user home
                            print("pic uploaded")
                            //  self.performSegueWithIdentifier("goHomeFromUpload", sender: self)
                        }else {
                            print(error)
                        }
                    })
                }else {
                    print(error)
                }
            })
        }
    }
    
    
    // MARK: UIImagePickerControllerDelegate method implementation
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        saveImageLocally()
        saveImageInDatabase()
        
        dismissViewControllerAnimated(true, completion: nil)
        btnRemoveImage.hidden = false
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

