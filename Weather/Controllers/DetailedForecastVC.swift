//
//  DetailedForecastVC.swift
//  Weather
//
//  Created by Konstantine Tsirgvava on 21.02.23.
//

import UIKit

class DetailedForecastVC: UIViewController, UISheetPresentationControllerDelegate {
    
    override var sheetPresentationController: UISheetPresentationController?{
        presentationController as? UISheetPresentationController
    }
    
    //MARK: - IBOulets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var noData: UILabel!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setDetailedForecast()
        updateView(with: ViewController.weatherModel!)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.reloadData()
        UserDefaults.standard.set(true, forKey: "firstSelected")
    }
    
    //MARK: - Methods
    private func setDetailedForecast(){
        let blur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        view.backgroundColor = .clear
        blurView.frame = view.bounds
        view.addSubview(blurView)
        view.sendSubviewToBack(blurView)
        
        let smallId = UISheetPresentationController.Detent.Identifier("small")
        let smallDetent = UISheetPresentationController.Detent.custom(identifier: smallId) { context in
            return 330
        }
        noData.layer.isHidden = ViewController.forecast.count == 0 ? false : true

        sheetPresentationController?.delegate = self
        sheetPresentationController?.prefersGrabberVisible = true
        sheetPresentationController?.detents = [smallDetent,.medium(), .large()]
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
    private func updateView(with model: WeatherModel){
        let date = Date(timeIntervalSince1970: TimeInterval(model.dt))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        cityLabel.text = "\(model.cityName)"
        dateLabel.text = "\(dateFormatter.string(from: date))"
        detailLabel.text = "Feels like : \(model.feelsLike.toString()) °C \nThe high will be : \(model.temp_max.toString()) °C \nThe low will be : \(model.temp_min.toString()) °C \nHumidity : \(model.humidity.toString()) % \nWind speed: \(model.windSpeed.toString()) m/s"
        collectionView.reloadData()
    }
}

//MARK: - Collection View
extension DetailedForecastVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ViewController.forecast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ForecastCollectionViewCell
        let forecast = ViewController.forecast[indexPath.row]
        if UserDefaults.standard.bool(forKey: "firstSelected") {
            collectionView.selectItem(at: [0,0], animated: true, scrollPosition: .top)
        }
        cell.configure(with: forecast)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let forecastData = ViewController.forecast[indexPath.row]
        let date = Date(timeIntervalSince1970: TimeInterval(forecastData.dt))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        dateLabel.text = "\(dateFormatter.string(from: date))"
        detailLabel.text = "Feels like : \(forecastData.feels_like.day.toString()) °C \nThe high will be : \(forecastData.temp.max.toString()) °C \nThe low will be : \(forecastData.temp.min.toString()) °C \nHumidity : \(forecastData.humidity.toString()) % \nWind speed: \(forecastData.wind_speed.toString()) m/s"
        UserDefaults.standard.set(false, forKey: "firstSelected")
    }
}
