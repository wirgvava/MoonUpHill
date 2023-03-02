//
//  OneCallAPIData.swift
//  Weather
//
//  Created by konstantine on 01.03.23.
//

import Foundation

// MARK: - Welcome
struct ForecastWeatherData: Decodable {
    let lat, lon: Double
    let daily: [Daily]
    
    var forecastModel: ForecastModel {
        return ForecastModel(dt: daily.first?.dt ?? 0,
                             temp: daily.first?.temp.day ?? 0,
                             description: daily.first?.weather.description ?? "")
    }
}

// MARK: - Weather
struct ForecastWeather: Decodable {
    let id: Int
    let description: String
}

// MARK: - Daily
struct Daily: Decodable {
    let dt: Int
    let temp: Temp
    let weather: [ForecastWeather]
}


// MARK: - Temp
struct Temp: Decodable {
    let day: Double
}

struct ForecastModel {
    let dt: Int
    let temp: Double
    let description: String
}
