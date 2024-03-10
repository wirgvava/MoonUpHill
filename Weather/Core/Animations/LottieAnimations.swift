//
//  LottieAnimations.swift
//  Weather
//
//  Created by Konstantine Tsirgvava on 06.03.24.
//

import UIKit
import Lottie

class LottieAnimations {
    static func birdsAnimation(on view: UIView){
        let birds = LottieAnimationView(name: "birds")
        birds.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: (view.frame.height) / 2)
        birds.contentMode = .scaleAspectFit
        birds.loopMode = .loop
        birds.play()
        view.addSubview(birds)
    }
    
    static func conditionAnimation(on view: UIView, name: String) {
        let animation = LottieAnimationView(name: name)
        animation.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        animation.loopMode = .loop
        animation.contentMode = .scaleAspectFill
        animation.play()
        view.addSubview(animation)
    }
    
    static func animate(background: UIView, with model: WeatherModel){
        switch model.conditionId {
        case 200...599:
            LottieAnimations.conditionAnimation(on: background, name: "rain")
        case 600...699:
            LottieAnimations.conditionAnimation(on: background, name: "snow")
        default:
            return
        }
    }
}
