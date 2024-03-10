//
//  CoreMotionAnimations.swift
//  Weather
//
//  Created by Konstantine Tsirgvava on 06.03.24.
//

import Lottie
import CoreMotion

class CoreMotionAnimations {
    
    static let motionManager = CMMotionManager()
    
    static func locationAnimation(animView: LottieAnimationView){
        animView.contentMode = .scaleAspectFit
        animView.loopMode = .repeat(1.5)
        animView.play()
        motionManager.deviceMotionUpdateInterval = 0.01        // CoreMotion
        motionManager.startDeviceMotionUpdates(to: .main) { (data, error) in
            guard let data = data, error == nil else { return }
            let rotation = atan2(data.gravity.x, data.gravity.y) - .pi
            animView.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
        }
    }
    
    static func stopAccelerometerUpdates(){
        motionManager.stopAccelerometerUpdates()
    }
}
