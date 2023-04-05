//
//  DetailedForecastVC.swift
//  Weather
//
//  Created by Konstantine Tsirgvava on 21.02.23.
//

import UIKit

class DetailedForecastVC: UIViewController, UISheetPresentationControllerDelegate {
    
    //MARK: - Variables & Constants
    let weatherManager = WeatherManager()
    let forecast = WeatherManager.forecastWeather
    override var sheetPresentationController: UISheetPresentationController?{
        presentationController as? UISheetPresentationController
    }
    
    //MARK: - Oulets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setDetailedForecast()
        fetchWeather()
//        weatherManager.fetchForecast()
        print("lat: \(ViewController.lat), lon: \(ViewController.lon)")

    }
    
    //MARK: - Methods
    private func setDetailedForecast(){
        let blur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        view.backgroundColor = .clear
        blurView.frame = view.bounds
        view.addSubview(blurView)
        view.sendSubviewToBack(blurView)
        sheetPresentationController?.delegate = self
        sheetPresentationController?.prefersGrabberVisible = true
        sheetPresentationController?.selectedDetentIdentifier = .medium
        sheetPresentationController?.detents = [.medium(), .large()]
        sheetPresentationController?.preferredCornerRadius = 22
        // collectionView Shadow
        collectionView.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        collectionView.layer.shadowOffset = CGSize(width: 2, height: 2)
        collectionView.layer.shadowRadius = 2.5
        collectionView.layer.shadowOpacity = 0.3
        self.collectionView.reloadData()
    }
}

//MARK: - Detail Information
extension DetailedForecastVC {
    private func fetchWeather(){
        let city = ViewController.cityName
        weatherManager.fetchWeather(byCity: city) { [weak self](result) in
            guard let this = self else {return}
            this.handleResult(result)
        }
    }

    private func handleResult(_ result: Result<WeatherModel, Error>){
        switch result {
        case .success(let model):
            updateView(with: model)
        case .failure:
            print("Error at Detail Information")
        }
    }

    private func updateView(with model: WeatherModel){
        let date = Date(timeIntervalSince1970: TimeInterval(model.dt))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        cityLabel.text = "\(model.cityName)"
        dateLabel.text = "\(dateFormatter.string(from: date))"
        detailLabel.text = "Feels like : \(model.feelsLike.toString()) °C \nThe high will be : \(model.temp_max.toString()) °C \nThe low will be : \(model.temp_min.toString()) °C \nHumidity : \(model.humidity.toString()) % \nWind speed: \(model.windSpeed.toString()) m/s"
    }
}


//MARK: - Collection View
extension DetailedForecastVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return forecast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ForecastCollectionViewCell
        
        let forecast = forecast[indexPath.row]
        cell.configure(with: forecast)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let forecastData = forecast[indexPath.row]
        let date = Date(timeIntervalSince1970: TimeInterval(forecastData.dt))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        dateLabel.text = "\(dateFormatter.string(from: date))"
        detailLabel.text = "Feels like : \(forecastData.feels_like.day.toString()) °C \nThe high will be : \(forecastData.temp.max.toString()) °C \nThe low will be : \(forecastData.temp.min.toString()) °C \nHumidity : \(forecastData.humidity.toString()) % \nWind speed: \(forecastData.wind_speed.toString()) m/s"
    }
}
