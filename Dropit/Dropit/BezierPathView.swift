//
//  BezierPathView.swift
//  Dropit
//
//  Created by Andriy Bas on 8/30/15.
//  Copyright © 2015 Andriy Bas. All rights reserved.
//

import UIKit

class BezierPathView: UIView {
    
    var bezierPaths = [String:UIBezierPath]()
    
    func setPath(path: UIBezierPath?, named name : String) {
        bezierPaths[name] = path
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        for (_, path) in bezierPaths {
            path.stroke()
        }
    }

}
