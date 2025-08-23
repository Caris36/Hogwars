//
//  Animations.swift
//  Hogwars
//
//  Created by Eugene Tan on 23/8/25.
//

import Foundation
import SceneKit
import ARKit

class Animations {
    
    func timeRange(forStartingAtFrame start:Int, endingAtFrame end:Int, fps:Double = 30) -> (offset:TimeInterval, duration:TimeInterval) {
        let startTime   = self.time(atFrame: start, fps: fps) //TimeInterval(start) / fps
        let endTime     = self.time(atFrame: end, fps: fps) //TimeInterval(end) / fps
        return (offset:startTime, duration:endTime - startTime)
    }

    func time(atFrame frame:Int, fps:Double = 30) -> TimeInterval {
        return TimeInterval(frame) / fps
    }

    func animation(from full:SCNAnimation, startingAtFrame start:Int, endingAtFrame end:Int, fps:Double = 30) -> CAAnimation {
        let range = self.timeRange(forStartingAtFrame: start, endingAtFrame: end, fps: fps)
        let animation = CAAnimationGroup()
        let sub = full.copy() as! SCNAnimation
        sub.timeOffset = range.offset
        animation.animations = [CAAnimation(scnAnimation: sub)]
        animation.duration = range.duration
        return animation
    }
}
