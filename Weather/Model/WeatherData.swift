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
    let coord: Coord
    var model: WeatherModel{
        return WeatherModel(cityName: name,
                            temp: main.temp,
                            conditionId: weather.first?.id ?? 0,
                            conditionDescription: weather.first?.description ?? "",
                            lat: coord.lat,
                            lon: coord.lon)
    }
}

struct Coord: Decodable {
    let lat, lon: Double
}

struct Weather: Decodable {
    let id: Int
    let main: String
    let description: String
    
    var conditionImage: String{
        switch id{
        case 200...299:
            return "imThunder"
        case 300...399:
            return "imDrizzle"
        case 500...599:
            return "imRain"
        case 600...699:
            return "imSnow"
        case 700...799:
            return "imAtmosphere"
        case 800:
            return "imClear"
        default:
            return "imCloud"
        }
    }
}

struct Main: Decodable {
    let temp: Double
}


struct WeatherModel {
    let cityName: String
    let temp: Double
    let conditionId: Int
    let conditionDescription: String
    let lat, lon: Double
    
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


// Forecast
struct ForecastWeatherData: Decodable {
    let daily: [Daily]
}

struct Daily: Decodable {
    let dt: Int
    let temp: Temperature
    let weather: [Weather]
}

struct Temperature: Decodable {
    let day: Double
}
