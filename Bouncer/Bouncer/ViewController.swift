//
//  ViewController.swift
//  Bouncer
//
//  Created by Andriy Bas on 9/3/15.
//  Copyright © 2015 Andriy Bas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let bouncer = BouncerBehavior()
    
    lazy var animator: UIDynamicAnimator = {
        UIDynamicAnimator(referenceView: self.view)
        }()
    
    var block: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator.addBehavior(bouncer)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (block == nil) {
            block = addBlock()
            block?.backgroundColor = UIColor.redColor()
            bouncer.addBlock(block!)
        }
        
        let motionManager = AppDelegate.Motion.Manager
        if motionManager.accelerometerAvailable {
            
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data, error) -> Void in
                self.bouncer.gravity.gravityDirection = CGVector(dx: data!.acceleration.x, dy: -data!.acceleration.y)
            })
            
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.Motion.Manager.stopAccelerometerUpdates()
    }
    
    struct Constants {
        static let blockSize: CGSize = CGSize(width: 40, height: 40)
    }
    
    private func addBlock() -> UIView {
        let block = UIView(frame: CGRect(origin: CGPointZero, size: Constants.blockSize))
        block.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        self.view.addSubview(block)
        return block
    }
    
    

}

