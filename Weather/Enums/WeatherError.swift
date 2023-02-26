//
//  WeatherError.swift
//  Weather
//
//  Created by konstantine on 22.02.23.
//

import Foundation

enum WeatherError: Error, LocalizedError {
    case invalidCity
    case custom(description: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCity:
            return "This is invalid City. Please try again!"
        case .custom(let description):
            return description
        }
    }
    
    
}
