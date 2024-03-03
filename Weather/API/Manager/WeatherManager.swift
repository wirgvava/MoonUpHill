//
//  WeatherData.swift
//  Weather
//
//  Created by konstantine on 22.02.23.
//

import Foundation
import Alamofire

class WeatherManager {
   
    private let API_KEY = Bundle.main.infoDictionary?["API_KEY"] as? String ?? ""
    
    //MARK: - Fetch weather by location
    func fetchWeather(lat: Double, lon: Double, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        let url = "https://api.openweathermap.org/data/2.5/weather?appid=\(API_KEY)&units=metric&lat=\(lat)&lon=\(lon)"
        handleRequest(urlString: url, completion: completion)
    }
    
    //MARK: - Fetch weather by city name
    func fetchWeather(byCity city: String, completion: @escaping (Result<WeatherModel, Error>) -> Void){
        let query = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city
        let url = "https://api.openweathermap.org/data/2.5/weather?q=\(query)&appid=\(API_KEY)&units=metric"
        handleRequest(urlString: url, completion: completion)
    }
    
    //MARK: - Fetch forecast
    func fetchForecast(lat: Double, lon: Double, completion: @escaping (Result<[Daily], Error>) -> ()){
        let url = "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&exclude=current,minutely,hourly,alerts&appid=\(API_KEY)&units=metric"
        AF.request(url).validate()
            .responseDecodable(of: ForecastWeatherData.self, queue: .main, decoder: JSONDecoder()) { response in
                switch response.result {
                case .success(let forecastData):
                    let daily = forecastData.daily
                    completion(.success(daily))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
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
    
    //MARK: - Custom Error
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
