//
//  WeatherData.swift
//  Weather
//
//  Created by konstantine on 22.02.23.
//

import Foundation

struct WeatherData: Decodable {
    let name: String
    let weather: [Weather]
    let main: Main
    var model: WeatherModel{
        return WeatherModel(cityName: name,
                            temp: main.temp,
                            conditionId: weather.first?.id ?? 0,
                            conditionDescription: weather.first?.description ?? "")
    }
}

struct Weather: Decodable {
    let id: Int
    let main: String
    let description: String
}

struct Main: Decodable {
    let temp: Double
}


struct WeatherModel {
    let cityName: String
    let temp: Double
    let conditionId: Int
    let conditionDescription: String
   
    var conditionBackground: String{
        switch conditionId{
        case 200...299:
            return "Thunder"
        case 300...399:
            return "Rainy"
        case 500...599:
            return "Rainy"
        case 600...699:
            return "Snowy"
        case 700...799:
            return "Rainy"
        case 800:
            return "Sunny"
        default:
            return "Rainy"
        }
    }
}
