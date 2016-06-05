//
//  ShowFriendsTableViewController.swift
//  Drop
//
//  Created by Aashna Garg on 5/28/16.
//  Copyright © 2016 Aashna Garg. All rights reserved.
//

import UIKit

class ShowFriendsTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    var friends: [String] = [String]()
    let popoverVc = FriendDetailsViewController()
    @IBOutlet weak var editButton: UIButton!
    
    @IBAction func goToMain(sender: AnyObject) {
           self.performSegueWithIdentifier("splitViewSegue", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popoverVc.modalPresentationStyle = .Popover
        popoverVc.preferredContentSize = CGSizeMake(50, 100)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    

    @IBAction func editButtonPressed(sender: AnyObject) {
        self.editing = !self.editing
        editButton.selected = !editButton.selected
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friend", forIndexPath: indexPath) as! ShowFriendsTableViewCell

        let cellDataParse: String = self.friends[indexPath.row]
        cell.friendName.text = cellDataParse
        return cell
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            self.friends.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        let itemToMove = self.friends[fromIndexPath.row]
        self.friends.removeAtIndex(fromIndexPath.row)
        self.friends.insert(itemToMove, atIndex: toIndexPath.row)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "friendDetails" {
            let friendDetailsVC = segue.destinationViewController as! FriendDetailsViewController, _ = self.tableView.indexPathForSelectedRow
            
            friendDetailsVC.modalPresentationStyle = UIModalPresentationStyle.Popover
            friendDetailsVC.popoverPresentationController!.delegate = self
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }


