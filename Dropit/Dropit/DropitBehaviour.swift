//
//  DropitBehaviour.swift
//  Dropit
//
//  Created by Andriy Bas on 8/30/15.
//  Copyright © 2015 Andriy Bas. All rights reserved.
//

import UIKit

class DropitBehaviour: UIDynamicBehavior {

    let gravity = UIGravityBehavior()
    
    lazy var collider: UICollisionBehavior = {
        let lazyCollider = UICollisionBehavior()
        lazyCollider.translatesReferenceBoundsIntoBoundary = true
        return lazyCollider
        }()
    
    lazy var dropBehaviour: UIDynamicItemBehavior = {
        let lazyItemBehaviour = UIDynamicItemBehavior()
        lazyItemBehaviour.allowsRotation = true
        lazyItemBehaviour.elasticity = 0.75
        return lazyItemBehaviour
        }()
    
    override init() {
        super.init()
        
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(dropBehaviour)
    }
    
    func addBarrier(path: UIBezierPath, named name: String) {
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func addDrop(dropView: UIView) {
        dynamicAnimator?.referenceView?.addSubview(dropView)
        gravity.addItem(dropView)
        collider.addItem(dropView)
        dropBehaviour.addItem(dropView)
    }
    
    func removeDrop(dropView: UIView) {
        gravity.removeItem(dropView)
        collider.removeItem(dropView)
        dropBehaviour.removeItem(dropView)
        dropView.removeFromSuperview()
    }
    
}
