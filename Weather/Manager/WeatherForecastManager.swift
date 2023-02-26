//
//  WeatherForecastManager.swift
//  Weather
//
//  Created by konstantine on 26.02.23.
//

import Foundation

class WeatherForecastManager {
    
    private let API_Key = "e9cb2dcf9178428fa8d174203232602"
    let query = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city
    let days = 1
    let path = "https://api.weatherapi.com/v1/forecast.json?key=%@&q=%@&days=%@&aqi=no&alerts=no"    
}
