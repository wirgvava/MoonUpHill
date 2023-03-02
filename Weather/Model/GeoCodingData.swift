//
//  GeocodingData.swift
//  Weather
//
//  Created by konstantine on 01.03.23.
//

import Foundation

struct GeocodingResponse: Decodable {
    let name: String
    let lat: Double
    let lon: Double
    let forecastWeather: ForecastWeatherData
}
