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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.dataParse.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        
        let cell = tableView.dequeueReusableCellWithIdentifier("friends", forIndexPath: indexPath) as! AddFriendsTableViewCell
        
        let cellDataParse:PFObject = self.dataParse.objectAtIndex(indexPath.row) as! PFObject
        
         return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print("INSIDE HERE")
       let contacts = fetchContactsFromAddressBook()
        let friendsList  = fetchContactsFromParse(contacts)
               print("Friends = \(friendsList)")

}
}
