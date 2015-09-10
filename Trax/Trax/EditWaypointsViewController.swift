//
//  EditWaypointsViewController.swift
//  Trax
//
//  Created by Andriy Bas on 9/10/15.
//  Copyright © 2015 Andriy Bas. All rights reserved.
//

import UIKit

class EditWaypointsViewController: UIViewController, UITextFieldDelegate {

    
    //MARK: Views
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField?.delegate = self
        }
    }
    @IBOutlet weak var infoTextField: UITextField! {
        didSet {
            infoTextField?.delegate = self
        }
    }
    
    // MARK: Vars
    var waypoint: EditableWaypoint? {
        didSet { updateUI() }
    }
    
    var ntfObserver: NSObjectProtocol?
    var itfObserver: NSObjectProtocol?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        self.nameTextField?.becomeFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        observeTextFields()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let center = NSNotificationCenter.defaultCenter()
        if ntfObserver != nil {
            center.removeObserver(ntfObserver!)
        }
        if itfObserver != nil {
            center.removeObserver(itfObserver!)
        }
    }
    
    // MARK: Image
    
    var imageView = UIImageView()
    
    @IBOutlet weak var imageVIewContainer: UIView! {
        didSet { imageVIewContainer.addSubview(imageView) }
    }
    
    
    // MARK: IBAction
    
    @IBAction func onDoneClick(sender: UIBarButtonItem) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Custom funcs
    
    func observeTextFields() {
        let nc = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        ntfObserver = nc.addObserverForName(UITextFieldTextDidChangeNotification, object: nameTextField, queue: queue) { (notification) -> Void in
            if let waypoint = self.waypoint {
                waypoint.name = self.nameTextField?.text
            }
        }
        itfObserver = nc.addObserverForName(UITextFieldTextDidChangeNotification, object: infoTextField, queue: queue) { (notification) -> Void in
            if let waypoint = self.waypoint {
                waypoint.info = self.infoTextField?.text
            }
        }
    }
    
    
    func updateUI() {
        self.nameTextField?.text = waypoint?.name
        self.infoTextField?.text = waypoint?.info
        
        updateImage()
    }
    
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.nameTextField {
            self.nameTextField.resignFirstResponder()
            self.infoTextField.becomeFirstResponder()
        } else if textField == self.infoTextField {
            self.infoTextField.resignFirstResponder()
        }
        return false
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension EditWaypointsViewController {
    func updateImage() {
        if let url = waypoint?.imageURL {
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos, 0)) { [weak self] () -> Void in
                do {
                    let imageData = try NSData(contentsOfURL: url, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    if let image = UIImage(data: imageData) {
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            self?.imageView.image = image
                            self?.makeRoomForImage()
                        }
                    }
                } catch _ {
                    print("error loading image")
                }
            }
        }
    }
    
    func makeRoomForImage() {
        var extraHeight: CGFloat = 0
        if imageView.image?.aspectRatio > 0 {
            if let width = imageView.superview?.frame.size.width {
                let height = width / imageView.image!.aspectRatio
            
                extraHeight = height - imageView.frame.height
                imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            }
        } else {
            extraHeight = -imageView.frame.height
            imageView.frame = CGRectZero
        }
        preferredContentSize = CGSize(width: preferredContentSize.width, height: preferredContentSize.height + extraHeight)
    }
}

extension UIImage {
    var aspectRatio: CGFloat {
        return size.height != 0 ? size.width / size.height : 0;
    }
}



