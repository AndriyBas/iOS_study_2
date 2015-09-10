//
//  BouncerHehavior.swift
//  Bouncer
//
//  Created by Andriy Bas on 9/3/15.
//  Copyright © 2015 Andriy Bas. All rights reserved.
//

import UIKit

class BouncerBehavior: UIDynamicBehavior {
    
    let gravity = UIGravityBehavior()
    
    lazy var collider: UICollisionBehavior = {
        let lazyCollider = UICollisionBehavior()
        lazyCollider.translatesReferenceBoundsIntoBoundary = true
        return lazyCollider
        }()
    
    lazy var blockBehaviour: UIDynamicItemBehavior = {
        let lazyItemBehaviour = UIDynamicItemBehavior()
        lazyItemBehaviour.allowsRotation = true
        lazyItemBehaviour.elasticity = 0.85
        lazyItemBehaviour.friction = 0
        lazyItemBehaviour.resistance = 0
        return lazyItemBehaviour
    }()
    
    override init() {
        super.init()
        
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(blockBehaviour)
    }
    
    func addBarrier(path: UIBezierPath, named name: String) {
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func addBlock(blockView: UIView) {
        dynamicAnimator?.referenceView?.addSubview(blockView)
        gravity.addItem(blockView)
        collider.addItem(blockView)
        blockBehaviour.addItem(blockView)
    }
    
    func removeBlock(blockView: UIView) {
        gravity.removeItem(blockView)
        collider.removeItem(blockView)
        blockBehaviour.removeItem(blockView)
        blockView.removeFromSuperview()
    }
    
}
