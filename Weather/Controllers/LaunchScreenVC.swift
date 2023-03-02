//
//  LaunchScreenVC.swift
//  Weather
//
//  Created by konstantine on 20.02.23.
//

import UIKit
import Lottie

class LaunchScreenVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        lottieAnimation()
    }
    
    
    func lottieAnimation(){
        let launchAnimation = LottieAnimationView(name: "launchScreen")
        launchAnimation.frame = CGRect(x: 0, y: 0, width: 250, height: 250)
        launchAnimation.center = self.view.center
        launchAnimation.contentMode = .scaleAspectFill
        view.addSubview(launchAnimation)
        launchAnimation.play()
        launchAnimation.loopMode = .autoReverse
    }
}
