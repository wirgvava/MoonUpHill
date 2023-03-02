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
    let current: Current
    let daily: [Daily]
}

// MARK: - Current
struct Current: Decodable {
    let dt: Int
    let temp: Double
    let weather: [ForecastWeather]
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

