//
//  WeatherData.swift
//  Weather
//
//  Created by konstantine on 22.02.23.
//

import Foundation
import Alamofire

class WeatherManager {
    
    var forecastWeather: [ForecastModel] = []
    private let API_KEY = "a1f8100b3fac9d0771123ea99dc27a04"
    
    
    // fetching OneCall API by Lat & Lon for daily forecast
    func forecastFetch(lat: Double, lon: Double, completion: @escaping (Result<ForecastModel, Error>) -> Void){
        let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&appid=\(API_KEY)"
//        let urlString = String(format: path, lat, lon, API_KEY)

        AF.request(urlString)
            .validate()
            .responseDecodable(of: ForecastWeatherData.self, queue: .main, decoder: JSONDecoder()) { (response) in
            switch response.result {
            case .success(let forecastWeatherData):
                let forecastModel = forecastWeatherData.forecastModel
                self.forecastWeather.append(forecastModel)
                completion(.success(forecastModel))
            case .failure(let error):
                if let err = self.getWeatherError(error: error, data: response.data) {
                    completion(.failure(err))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }

    
    // fetch by Location
    func fetchWeather(lat: Double, lon: Double, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        let path = "https://api.openweathermap.org/data/2.5/weather?appid=%@&units=metric&lat=%f&lon=%f"
        let urlString = String(format: path, API_KEY, lat, lon)
        handleRequest(urlString: urlString, completion: completion)
    }
    
    // fetch by City
    func fetchWeather(byCity city: String, completion: @escaping (Result<WeatherModel, Error>) -> Void){
        let query = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city
        let path = "https://api.openweathermap.org/data/2.5/weather?q=%@&appid=%@&units=metric"
        let urlString = String(format: path, query, API_KEY)
        handleRequest(urlString: urlString, completion: completion)
    }
    
    private func handleRequest(urlString: String, completion: @escaping (Result<WeatherModel, Error>) -> Void){
        
        AF.request(urlString)
            .validate()
            .responseDecodable(of: WeatherData.self, queue: .main, decoder: JSONDecoder()) { (response) in
            switch response.result {
            case .success(let weatherData):
                let model = weatherData.model
                completion(.success(model))
            case .failure(let error):
                if let err = self.getWeatherError(error: error, data: response.data) {
                    completion(.failure(err))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // Custom error
    private func getWeatherError(error: AFError, data: Data?) -> Error? {
        if error.responseCode == 404,
            let data = data,
            let failure = try? JSONDecoder().decode(WeatherDataFailure.self, from: data){
            let message = failure.message
            return WeatherError.custom(description: message)
        } else {
            return nil
        }
    }
    
}
