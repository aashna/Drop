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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsets(top: 28, left: 0, bottom: 0, right: 0)
        self.tableView.allowsMultipleSelection = true
        print("INSIDE HERE")
        let contacts = fetchContactsFromAddressBook()
        self.dataParse = fetchContactsFromParse(contacts)
       
        
//        self.dataParse.addObject("abc")
//        self.dataParse.addObject("def")
//        self.dataParse.addObject("ghi")
//        self.dataParse.addObject("xyz")
        
        //  print("Friends = \(friendsList)")
        
        let barBack = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(AddFriendsTableViewController.backButtonPressed))
        self.navigationItem.leftBarButtonItem = barBack
    }

    
    func backButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
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
    
    func fetchContactsFromParse(contacts:[CNContact]) -> NSMutableArray{
        var queries = [PFQuery]()

        for contact in contacts{
            var phoneStr : String
//            var nameStr : String
//            var number: CNPhoneNumber!
            if contact.phoneNumbers.count > 0 {
                phoneStr = (contact.phoneNumbers[0].value as! CNPhoneNumber).valueForKey("digits") as! String
            } else {
                phoneStr = ""
            }
//            nameStr = contact.familyName + contact.givenName
           // print(nameStr)
           
           // print(phoneStr)
//            if(phoneStr == "9868460133"){
//              print("YES!!!")
//            }
         
            
            let query = PFQuery(className: "_User")
             queries.append(query.whereKey("phone",equalTo: "\(phoneStr)"))
            }
            var query = PFQuery(className: "_User")
            query = PFQuery.orQueryWithSubqueries(queries)
            
           
            query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                if error == nil {
                    print("Successfully retrieved:")
                    if let objects = objects as [PFObject]! {
                        for object in objects {
                            //For each object in the class object, append it to myArray
                            //self.friends.append(object.objectForKey("username") as! String)
                        self.dataParse.addObject(object.objectForKey("username") as! String)
                        self.tableView.reloadData()
                            
                        }
                        
                    }
                    
                } else {
                    print("Error: \(error) \(error!.userInfo)")
                    
                }
            }
        //let array:NSArray = self.dataParse.reverseObjectEnumerator().allObjects
        //self.dataParse = array as NSArray as! [String]
        
      //  self.tableView.reloadData()
        print("dataparse = \(dataParse)")
        return self.dataParse
        
    }
    
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
        let cellDataParse: String = self.dataParse.objectAtIndex(indexPath.row) as! String
        cell.friendName.text = cellDataParse
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
                    friends.append(self.dataParse[indexPath.row] as! String)
                }  
            }
             showFriendsVC.friends = self.friends//self.dataParse as NSArray as! [String]
        }
        
    }
    
}
