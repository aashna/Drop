//
//  AddFriendsViewController.swift
//  Drop
//
//  Created by Aashna Garg on 5/22/16.
//  Copyright © 2016 Aashna Garg. All rights reserved.
//

import UIKit
import Contacts
import AddressBook
import Parse


class AddFriendsTableViewController: UITableViewController {
            var friends: [String] = [String]()
            var dataParse:NSMutableArray = NSMutableArray()
    
    func fetchContactsFromAddressBook() -> [CNContact] {
        var contacts: [CNContact]! = []
        AppDelegate.getAppDelegate().requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                let contactsStore = AppDelegate.getAppDelegate().contactStore
                let keysToFetch = [
                    CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
                    CNContactEmailAddressesKey,
                    CNContactPhoneNumbersKey,
                    CNContactImageDataAvailableKey,
                    CNContactThumbnailImageDataKey]
                
                let predicate = CNContact.predicateForContactsInContainerWithIdentifier(contactsStore.defaultContainerIdentifier())
                
                do {
                    contacts = try contactsStore.unifiedContactsMatchingPredicate(predicate, keysToFetch: keysToFetch)// [CNContact]
                }catch {
                    
                }
                for contact in contacts {
                    var phoneStr = ""
                    var nameStr = ""
                    var number: CNPhoneNumber!
                    if contact.phoneNumbers.count > 0 {
                        number = contact.phoneNumbers[0].value as! CNPhoneNumber
                        phoneStr = number.stringValue.stringByReplacingOccurrencesOfString("-", withString: "")
                    }
                    nameStr = contact.familyName + contact.givenName
//                    print(nameStr)
//                    print(phoneStr)
//                    if !nameStr.isEmpty && !phoneStr.isEmpty {
//                        let friend = YFriendsModel()
//                        friend.name = nameStr
//                        friend.phone = phoneStr
//                        self.friendArr.append(friend)
//                    }
                    
                }}}

          return contacts   }
    
    func fetchContactsFromParse(contacts:[CNContact]) -> Void{
        var queries = [PFQuery]()

        for contact in contacts{
            var phoneStr = ""
            var nameStr = ""
            var number: CNPhoneNumber!
            if contact.phoneNumbers.count > 0 {
                phoneStr = (contact.phoneNumbers[0].value as! CNPhoneNumber).valueForKey("digits") as! String
            }
            nameStr = contact.familyName + contact.givenName
           // print(nameStr)
           
            print(phoneStr)
//            if(phoneStr == "9868460133"){
//              print("YES!!!")
//            }
         
            
            var query = PFQuery(className: "_User")
             queries.append(query.whereKey("phone",equalTo: "\(phoneStr)"))
            }
            var query = PFQuery(className: "_User")
            query = PFQuery.orQueryWithSubqueries(queries)
            
           
            query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                if error == nil {
                    print("Successfully retrieved: \(objects)")
                    if let objects = objects as? [PFObject]! {
                        for object in objects {
                            
                            //For each object in the class object, append it to myArray
                            //self.friends.append(object.objectForKey("username") as! String)
                            self.dataParse.addObject(object)
                            
                        }
                        
                    }
                    
                } else {
                    print("Error: \(error) \(error!.userInfo)")
                    
                }
            }
        let array:NSArray = self.dataParse.reverseObjectEnumerator().allObjects
        self.dataParse = array as! NSMutableArray
        
        self.tableView.reloadData()

   //    return friends
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int
    {
        return 1
    }
    
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int
    {
        return self.dataParse.count
    }
    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        
//        let cell:TableViewCell = tableView!.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath!) as CustomCell
//        
//        let cellDataParse:PFObject = self.dataParse.objectAtIndex(indexPath.row) as! PFObject
//        
//        cell.mensajeBox.text = cellDataParse.objectForKey("NAME ROW IN YOUR DATABASE PARSE") as String; return cell
//    }
//    

    
                //    })
//
//                let predicate = CNContact.predicateForContactsMatchingName(self.txtLastName.text!)
//                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactImageDataKey]
//                var contacts = [CNContact]()
//                var message: String!
//                
//                let contactsStore = AppDelegate.getAppDelegate().contactStore
//                do {
//                    contacts = try contactsStore.unifiedContactsMatchingPredicate(predicate, keysToFetch: keys)
//                    
//                    if contacts.count == 0 {
//                        message = "No contacts were found matching the given name."
//                    }
//                }
//                catch {
//                    message = "Unable to fetch contacts."
//                }
//                
//                
//                if message != nil {
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        AppDelegate.getAppDelegate().showMessage(message)
//                    })
//                }
//                else {
//                    
//                }
//            }
        
        
      //  return true
    
    
 //   let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("INSIDE HERE")
       let contacts = fetchContactsFromAddressBook()
        let friendsList  = fetchContactsFromParse(contacts)
               print("Friends = \(friendsList)")
        
        
//        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
//        
//        switch authorizationStatus {
//        case .Denied, .Restricted:
//            //1
//            print("Denied")
//            displayCantAddContactAlert()
//        case .Authorized:
//            //2
//            print("Authorized")
//        case .NotDetermined:
//            //3
//            print("Not Determined")
//        }
//        promptForAddressBookRequestAccess()
//
//        // Do any additional setup after loading the view.
    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    func promptForAddressBookRequestAccess() {
//        var err: Unmanaged<CFError>? = nil
//        
//        ABAddressBookRequestAccessWithCompletion(addressBookRef) {
//            (granted: Bool, error: CFError!) in
//            dispatch_async(dispatch_get_main_queue()) {
//                if !granted {
//                    
//                    print("Just denied")
//                    self.displayCantAddContactAlert()
//                    
//                } else {
//                    print("Just authorized")
//                    self.searchInContacts()
//                }
//            }
//        }
//    }
//    func openSettings() {
//        let url = NSURL(string: UIApplicationOpenSettingsURLString)
//        UIApplication.sharedApplication().openURL(url!)
//    }
//    func displayCantAddContactAlert() {
//        let cantAddContactAlert = UIAlertController(title: "Cannot Add Contact",
//                                                    message: "You must give the app permission to add the contact first.",
//                                                    preferredStyle: .Alert)
//        cantAddContactAlert.addAction(UIAlertAction(title: "Change Settings",
//            style: .Default,
//            handler: { action in
//                self.openSettings()
//        }))
//        cantAddContactAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
//        presentViewController(cantAddContactAlert, animated: true, completion: nil)
//    }
//    
//    func searchInContacts(){
////       let allContacts = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue() as Array
////        for record in allContacts {
////            let currentContact: ABRecordRef = record
////            let currentContactName = ABRecordCopyCompositeName(currentContact).takeRetainedValue() as String
////            
////           // let petName = pet.description
////           // if (currentContactName == petName) {
////           //     println("found \(petName).")
////           //     petContact = currentContact
////           // }
////        }
//        var error: Unmanaged<CFError>?
//        let addressBook: ABAddressBookRef = {
//            return (ABAddressBookCreateWithOptions(nil, &error)?.takeRetainedValue())! as ABAddressBookRef
//        }()
////        if addressBook == nil {
////            print(error?.takeRetainedValue())
////            return
////        }
//        let people = ABAddressBookCopyArrayOfAllPeople(addressBook)?.takeRetainedValue() as? NSArray
//            // now do something with the array of people
//            
//            for record:ABRecordRef in people! {
//                print(record)
//                let phones : ABMultiValueRef = ABRecordCopyValue(record,kABPersonPhoneProperty).takeUnretainedValue() as ABMultiValueRef
//                
//                for var numberIndex in 0...ABMultiValueGetCount(phones){
////                for(var numberIndex : CFIndex = 0; numberIndex < ABMultiValueGetCount(phones); numberIndex++)
//                
//                    let phoneUnmaganed = ABMultiValueCopyValueAtIndex(phones, numberIndex)
//                    
//                    
//                    let phoneNumber : NSString = phoneUnmaganed.takeUnretainedValue() as! NSString
//                    
//                    let locLabel : CFStringRef = (ABMultiValueCopyLabelAtIndex(phones, numberIndex) != nil) ? ABMultiValueCopyLabelAtIndex(phones, numberIndex).takeUnretainedValue() as CFStringRef : ""
//                    
//                    let cfStr:CFTypeRef = locLabel
//                    let nsTypeString = cfStr as! NSString
//                    let swiftString:String = nsTypeString as String
//                    
//                    _ = String (stringInterpolationSegment: ABAddressBookCopyLocalizedLabel(locLabel))
//                    
//                    
//                    print("Name :-\(swiftString) NO :-\(phoneNumber)" )
//                
//            }
//            
//            
//        }
//    
//    }


}
