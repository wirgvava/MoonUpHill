//
//  AppAnalytics.swift
//  Weather
//
//  Created by Konstantine Tsirgvava on 10.03.24.
//

import Foundation
import FirebaseAnalytics

class AppAnalytics {
    static func logEvents(with name: EventNames, paramName: EventParams?, paramData: Any?) {
        if paramName == nil {
            Analytics.logEvent(name.rawValue, parameters: nil)
        } else {
            Analytics.logEvent(name.rawValue, parameters: [paramName!.rawValue : paramData!])
        }
    }

    enum EventNames: String {
        case location
        case opened_forecast
        case choosen_another_day
    }
    
    enum EventParams: String {
        case city
    }
}
