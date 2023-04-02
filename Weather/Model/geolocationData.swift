//
//  geolocationData.swift
//  Weather
//
//  Created by konstantine on 02.04.23.
//

import Foundation

struct GeolocationElements: Decodable {
    let name: String
    let lat, lon: Double
    var model: GeolocationModel{
        return GeolocationModel(lat: lat, lon: lon)
    }
}

typealias Geolocation = [GeolocationElements]

struct GeolocationModel {
    let lat, lon: Double
}
