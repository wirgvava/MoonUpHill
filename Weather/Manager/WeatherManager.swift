//
//  WeatherData.swift
//  Weather
//
//  Created by konstantine on 22.02.23.
//

import Foundation
import Alamofire

class WeatherManager {
    
    private let API_KEY = "a1f8100b3fac9d0771123ea99dc27a04"
    
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
