//
//  AddFriendsViewController.swift
//  Drop
//
//  Created by Aashna Garg on 5/22/16.
//  Copyright © 2016 Aashna Garg. All rights reserved.
//

import UIKit
import Contacts
import Parse


class AddFriendsTableViewController: UITableViewController {
    var friends: [String] = [String]()
    var dataParse: [(name: String, number: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsets(top: 28, left: 0, bottom: 0, right: 0)
        self.tableView.allowsMultipleSelection = true
        print("INSIDE HERE")
        _ = fetchContactsFromAddressBook()
//        self.dataParse = fetchContactsFromParse(contacts)
       
        
        self.dataParse.append((name:"Barbara Mori", number:"+1 415 888 3214"))
        self.dataParse.append((name:"Maria Duke", number:"+1 418 188 3314"))
        self.dataParse.append((name:"Ronaldo", number:"+1 415 168 3213"))
        self.dataParse.append((name:"Ayush Gupta", number:"+91 918 221 3894"))
        self.dataParse.append((name:"Jonhy Bravo", number:"+1 422 344 3244"))
        self.dataParse.append((name:"Katrina Heard", number:"+1 435 765 9814"))
        self.dataParse.append((name:"Rockstar", number:"+1 415 888 1234"))
        self.dataParse.append((name:"Narimaa De", number:"+1 418 188 4535"))
        self.dataParse.append((name:"Bellachio", number:"+1 415 168 7446"))
        self.dataParse.append((name:"Aashna Gupta", number:"+91 918 434 3894"))
        self.dataParse.append((name:"Belly Fernando", number:"+1 745 356 8668"))
        self.dataParse.append((name:"Manta Blow", number:"+1 635 115 1114"))

        
        //  print("Friends = \(friendsList)")
        
        let barBack = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(AddFriendsTableViewController.backButtonPressed))
        self.navigationItem.leftBarButtonItem = barBack
    }

    
    func backButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /**
     Referred from http://www.appcoda.com/ios-contacts-framework/
   *
   *
   */
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
                } catch {
                    
                }
//                for contact in contacts {
//                    var phoneStr : String
//                    var nameStr : String
//                    var number: CNPhoneNumber!
//                    if contact.phoneNumbers.count > 0 {
//                        number = contact.phoneNumbers[0].value as! CNPhoneNumber
//                        phoneStr = number.stringValue.stringByReplacingOccurrencesOfString("-", withString: "")
//                    }
//                    nameStr = contact.familyName + contact.givenName
//                    print(nameStr)
//                    print(phoneStr)
//                    if !nameStr.isEmpty && !phoneStr.isEmpty {
//                        let friend = YFriendsModel()
//                        friend.name = nameStr
//                        friend.phone = phoneStr
//                        self.friendArr.append(friend)
//                    }
                    
//                }
            }
        }

          return contacts   }
    
//    func fetchContactsFromParse(contacts:[CNContact]) -> NSMutableArray{
//        var queries = [PFQuery]()
//
//        for contact in contacts{
//            var phoneStr : String
////            var nameStr : String
////            var number: CNPhoneNumber!
//            if contact.phoneNumbers.count > 0 {
//                phoneStr = (contact.phoneNumbers[0].value as! CNPhoneNumber).valueForKey("digits") as! String
//            } else {
//                phoneStr = ""
//            }
////            nameStr = contact.familyName + contact.givenName
//           // print(nameStr)
//           
//           // print(phoneStr)
////            if(phoneStr == "9868460133"){
////              print("YES!!!")
////            }
//         
//            
//            let query = PFQuery(className: "_User")
//             queries.append(query.whereKey("phone",equalTo: "\(phoneStr)"))
//            }
//            var query = PFQuery(className: "_User")
//            query = PFQuery.orQueryWithSubqueries(queries)
//            
//           
//            query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
//                if error == nil {
//                    print("Successfully retrieved:")
//                    if let objects = objects as [PFObject]! {
//                        for object in objects {
//                            //For each object in the class object, append it to myArray
//                            //self.friends.append(object.objectForKey("username") as! String)
//                        self.dataParse.addObject(object.objectForKey("username") as! String)
//                        self.tableView.reloadData()
//                            
//                        }
//                        
//                    }
//                    
//                } else {
//                    print("Error: \(error) \(error!.userInfo)")
//                    
//                }
//            }
//        //let array:NSArray = self.dataParse.reverseObjectEnumerator().allObjects
//        //self.dataParse = array as NSArray as! [String]
//        
//      //  self.tableView.reloadData()
//        print("dataparse = \(dataParse)")
//        return self.dataParse
//        
//    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataParse.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friend", forIndexPath: indexPath) as! AddFriendsTableViewCell
//        let cellDataParse:PFObject = self.dataParse.objectAtIndex(indexPath.row) as! PFObject
//        cell.friendName.text =   cellDataParse.objectForKey("username") as? String
        let cellDataParse = self.dataParse.removeAtIndex(indexPath.row)
        self.dataParse.insert(cellDataParse, atIndex: indexPath.row)
        cell.friendName.text = cellDataParse.name
        cell.friendPhone.text = cellDataParse.number
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if case let showFriendsVC as ShowFriendsTableViewController  = segue.destinationViewController
            where segue.identifier == "showFriends"
        {
            
            for row in 0...self.dataParse.count{
                let indexPath = NSIndexPath(forRow: row, inSection: 0)
                if(tableView.cellForRowAtIndexPath(indexPath)?.accessoryType == UITableViewCellAccessoryType.Checkmark){
                    let cellDataParse = self.dataParse.removeAtIndex(indexPath.row)
                    self.dataParse.insert(cellDataParse, atIndex: indexPath.row)
                    friends.append(cellDataParse.name)
                }  
            }
             showFriendsVC.friends = self.friends//self.dataParse as NSArray as! [String]
        }
        
    }
    
}
