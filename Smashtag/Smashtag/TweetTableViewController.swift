//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Andriy Bas on 8/29/15.
//  Copyright © 2015 Andriy Bas. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate {

    @IBAction func refresh(sender: UIRefreshControl?) {
        if searchText != nil {
            if let request = nextRequestToAttempt {
                request.fetchTweets { (newTweets: [Tweet]) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if newTweets.count > 0 {
                            self.tweets.insert(newTweets, atIndex: 0)
                            self.tableView?.reloadData()
                            sender?.endRefreshing()
                        }
                    })
                }
            }
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
 
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == searchTextField {
            searchTextField.resignFirstResponder()
            searchText = searchTextField?.text
            return false
        }
        
        return true
    }
    
    var searchText: String? = "#stanford" {
        didSet {
            searchTextField?.text = searchText
            tweets.removeAll()
            self.tableView.reloadData()
            refresh()
        }
    }
    
    var tweets = [[Tweet]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        refresh()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    @IBAction func selectAlert(sender: UIBarButtonItem) {
        
        let alert = UIAlertController(
            title: "Go go",
            message: "Are you sure you want to go go?",
            preferredStyle: UIAlertControllerStyle.ActionSheet);
        
        alert.addAction(UIAlertAction(
            title: "Login",
            style: .Default,
            handler: { (action: UIAlertAction) -> Void in
             print("Login")
                self.showLogin()
        }))
        
        alert.addAction(UIAlertAction(
            title: "Timer",
            style: UIAlertActionStyle.Default,
            handler: { (action: UIAlertAction) -> Void in
                print("timer")
                self.startTimer()
        }))
        
        alert.addAction(UIAlertAction(
            title: "action 3",
            style: UIAlertActionStyle.Destructive,
            handler: { (action: UIAlertAction) -> Void in
                print("Action 3")
        }))
        
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: UIAlertActionStyle.Cancel,
            handler: { (action: UIAlertAction) -> Void in
                print("cancel")
        }))
        
        alert.modalPresentationStyle = .Popover
        let ppc = alert.popoverPresentationController
        ppc?.barButtonItem = sender
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    private func startTimer() {
        
        NSTimer.scheduledTimerWithTimeInterval(
            2.0,
            target: self,
            selector: Selector("timerAction:"),
            userInfo: ["a" : "b"],
            repeats: true)
        
    }
    
    func timerAction(timer: NSTimer) {
        print("wow:\(timer.userInfo)")
    }
    
    private func showLogin() {
        
        let alert = UIAlertController(title: "Login Required", message: "Login, you motherfucker", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction) -> Void in
            
        }))
        
        
        alert.addAction(UIAlertAction(title: "Login", style: UIAlertActionStyle.Default, handler: { [weak alert](action: UIAlertAction) -> Void in
            
            if let tf = alert?.textFields?.first {
                print("Pass:\(tf.text)")
            }
            
        }))
        
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.placeholder = "Enter password, you damn fool"
        }
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    var lastSuccessfulRequest: TwitterRequest?
    
    var nextRequestToAttempt: TwitterRequest? {
        if lastSuccessfulRequest == nil {
            if searchText != nil {
                return TwitterRequest(search: searchText!, count: 100)
            }
        } else {
            return lastSuccessfulRequest!.requestForNewer
        }
        return TwitterRequest(search: "#stanford", count: 100)
    }
    
    
    private func refresh() {
        if refreshControl != nil {
            refreshControl!.beginRefreshing()
        }
        refresh(refreshControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

    private struct Storyboard {
        static let CellReuseIdentifier = "TweetCell"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! TweetTableViewCell

        cell.tweet = tweets[indexPath.section][indexPath.row]
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
