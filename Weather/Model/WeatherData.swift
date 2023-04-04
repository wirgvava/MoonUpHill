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
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    var model: WeatherModel{
        return WeatherModel(lat: coord.lat,
                            lon: coord.lon,
                            cityName: name,
                            dt: dt,
                            temp: main.temp,
                            temp_min: main.temp_min,
                            temp_max: main.temp_max,
                            conditionId: weather.first?.id ?? 0,
                            conditionDescription: weather.first?.description ?? "",
                            feelsLike: main.feels_like,
                            humidity: main.humidity,
                            windSpeed: wind.speed,
                            clouds: clouds.all)
    }
}
// MARK: - Coordinates
struct Coord: Decodable {
    let lat, lon: Double
}

// MARK: - Weather
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

// MARK: - Temp
struct Main: Decodable {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let humidity: Int
}


// MARK: - Clouds
struct Clouds: Decodable {
    let all: Int
}


// MARK: - Wind
struct Wind: Decodable {
    let speed: Double
}


struct WeatherModel {
    let lat, lon: Double
    let cityName: String
    let dt: Int
    let temp, temp_min, temp_max: Double
    let conditionId: Int
    let conditionDescription: String
    let feelsLike: Double
    let humidity: Int
    let windSpeed: Double
    let clouds: Int
    
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


// MARK: - Forecast ---------------------------------------
struct ForecastWeatherData: Decodable {
    let daily: [Daily]
    
    var model: ForecastModel{
        return ForecastModel(dt: daily.first?.dt ?? 0,
                             feelsLike: daily.first?.feels_like.day ?? 0,
                             tempMin: daily.first?.temp.min ?? 0,
                             tempMax: daily.first?.temp.max ?? 0,
                             windSpeed: daily.first?.wind_speed ?? 0,
                             humidity: daily.first?.humidity ?? 0)
    }
}

struct Daily: Decodable {
    let dt: Int
    let temp: Temperature
    let feels_like: FeelsLike
    let humidity: Int
    let wind_speed: Double
    let weather: [Weather]
}

struct Temperature: Decodable {
    let day: Double
    let min: Double
    let max: Double
}

struct FeelsLike: Decodable {
    let day: Double
}

struct ForecastModel {
    let dt: Int
    let feelsLike, tempMin, tempMax: Double
    let windSpeed : Double
    let humidity: Int
}
