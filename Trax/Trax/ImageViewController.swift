//
//  ImageViewController.swift
//  Autolayout
//
//  Created by Andriy Bas on 8/24/15.
//  Copyright © 2015 Andriy Bas. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 2.5
            scrollView.delegate = self
        }
    }
    
    var imageView = UIImageView()
    
    var imageURL : NSURL? {
        didSet {
            image = nil
            if(self.view.window != nil) {
                fetchImage()
            }
        }
    }
    
    var image: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            spinner?.stopAnimating()
        }
    }
    
    private func fetchImage() {
        if(imageURL != nil) {
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            self.spinner?.startAnimating()
            dispatch_async(dispatch_get_global_queue(qos, 0)) { [unowned self]() -> Void in
                
                do {
                    let imageData = try NSData(contentsOfURL: self.imageURL!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    if let img = UIImage(data: imageData) {
                        dispatch_async(dispatch_get_main_queue()) { [unowned self]() -> Void in
                            self.image = img
                        }
                    }
                } catch _ {
                    print("cannot load image")
                }
            }
        } else {
            image = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.addSubview(imageView)
        
        let delta = Int64(5 * Double(NSEC_PER_SEC))
        print("delta = \(delta)")
        print("now = \(DISPATCH_TIME_NOW)")
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, delta)
        print("dispatchTime = \(dispatchTime)")
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), { [unowned self] () -> Void in
            print("log 5")
//            self.view.backgroundColor = self.view.backgroundColor
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
    }
    
    
    // MARK: UIScrollViewDelegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }


}
