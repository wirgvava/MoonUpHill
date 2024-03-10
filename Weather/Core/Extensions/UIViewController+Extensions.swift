//
//  UIViewController+Extensions.swift
//  Weather
//
//  Created by Konstantine Tsirgvava on 06.03.24.
//

import UIKit
import Loaf

extension UIViewController {
    func show(message: String, state: Loaf.State){
        Loaf(message, state: state, location: .bottom, presentingDirection: .left, dismissingDirection: .right, sender: self).show()
    }
}
