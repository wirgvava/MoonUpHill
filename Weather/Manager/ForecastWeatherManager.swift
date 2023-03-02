//
//  ForecastWeatherManager.swift
//  Weather
//
//  Created by konstantine on 28.02.23.
//

import Foundation
import Alamofire
import SwiftyJSON

/*
 Geocoding API - დან უნდა მივიღოთ ქალაქის(რომელსაც ჩვენ მივუთითებთ)გრძედის და განედის ინფორმაცია და შევინახოთ lat და lon-ი,
 რათა გამოვიყენოთ შემდეგი API - ისთვის რომელიც ითხოვს გრძედს და განედს ქალაქის სახელის ნაცვლად
 
 1. გავპარსოთ გეოქოდინგ აპი და ამოვიღოთ გრძედი და განედი   +++++++
 2. შევინახოთ გრძედი და განედი ცალკე  +++++++
 3. გავპარსოთ შემდეგი აპი ამ გრძედი და განედის ხარჯზე +++
 4. შევინახოთ ცალკე სელისთვის  dt, temp, description
 */
// TODO: - OneCall API not fetching data 
class ForecastWeatherManager {
    
    private let apiKey = "a1f8100b3fac9d0771123ea99dc27a04"
    var latitude: Double = 0
    var longitude: Double = 0
    var forecastWeather: [ForecastWeatherData] = []
    
    
    
    // fetching Geocodin API for getting Lat % Lon doubles of City for OneCall API
    func fetchLocationData(city: String){
        let query = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city
        let geocodingURL = "https://api.openweathermap.org/geo/1.0/direct?q=\(query)&limit=5&appid=\(apiKey)"
        
        AF.request(geocodingURL).validate().response { response in
            guard let data = response.data else { return }
            
            do {
                let decoder = JSONDecoder()
                let geocodingResponse = try decoder.decode([GeocodingResponse].self, from: data)

                // Save the lat, lon data here
                self.latitude = geocodingResponse[0].lat
                self.longitude = geocodingResponse[0].lon
//                self.forecastFetch(lat: self.lat, lon: self.lon, completion: completion)
                print("LOCATION: \(self.latitude), \(self.longitude)")

            } catch let error {
                print("ERROR: \(error.localizedDescription)")
            }
        }
    }
    
    
    
    
    // fetching OneCall API by Lat & Lon for daily forecast
//    func forecastFetch(lat: Double, lon: Double, completion: @escaping (Result<[GeocodingResponse], Error>) -> Void){
//        let forecastURL = "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&appid=\(apiKey)"
//
//        AF.request(forecastURL)
//            .validate()
//            .responseDecodable(of: ForecastWeatherData.self, queue: .main, decoder: JSONDecoder()) { (response) in
//                switch response.result {
//                case .success:
//                    guard let data = response.data else { return }
//
//                    do {
//                        let decoder = JSONDecoder()
//                        let forecastResponse = try decoder.decode([ForecastWeatherData].self, from: data)
//                        print(forecastResponse)
//                    } catch let error {
//                        print("ERROR1: \(error.localizedDescription)")
//                    }
//
//                case .failure(let error):
//                    print("ERROR2: \(error.localizedDescription)")
//                }
//        }
//    }
}
