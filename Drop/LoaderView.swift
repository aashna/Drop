//
//  loaderView.swift
//  Drop
//
//  Created by Ayush Gupta on 5/25/16.
//  Copyright © 2016 Aashna Garg. All rights reserved.
//

import UIKit

class LoaderView: UIView {
 
    @IBOutlet weak var icon1: UIImageView!
    @IBOutlet weak var Loading: UILabel!
    
    func addTonesMovement(beginTime: CFTimeInterval, duration: CFTimeInterval) -> CAKeyframeAnimation {
        let tonesMovement = CAKeyframeAnimation.init(keyPath: "position.x")
        tonesMovement.beginTime = beginTime
        tonesMovement.duration = duration
        tonesMovement.speed = 1.0
        tonesMovement.values = [0,120]
        tonesMovement.repeatCount = HUGE
        return tonesMovement
    }
    
    func addShimering() -> CAKeyframeAnimation {
        let shimmering = CAKeyframeAnimation.init(keyPath: "opacity")
        shimmering.values = [1, 0.2, 1]
        shimmering.duration = 2
        shimmering.repeatCount = HUGE
        return shimmering
    }
    
    func animateLoader() {
        icon1.layer.addAnimation(addTonesMovement(0.0, duration: 4), forKey: "basic")
        Loading.layer.addAnimation(addShimering(), forKey: "basic")
    }
}
