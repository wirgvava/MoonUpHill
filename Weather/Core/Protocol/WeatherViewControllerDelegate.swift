//
//  WeatherViewControllerDelegate.swift
//  Weather
//
//  Created by konstantine on 23.02.23.
//

import Foundation

protocol WeatherViewControllerDelegate: AnyObject {
    func didUpdateWeatherFromSearch(model: WeatherModel)
}
