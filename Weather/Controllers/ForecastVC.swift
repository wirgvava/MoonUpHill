//
//  ForecastVC.swift
//  Weather
//
//  Created by konstantine on 21.02.23.
//

import UIKit
import SwiftyJSON
import Loaf

class ForecastVC: UIViewController, UISheetPresentationControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override var sheetPresentationController: UISheetPresentationController?{
        presentationController as? UISheetPresentationController
    }
    let manager = ForecastWeatherManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchForecastWeather(byCity: "Tbilisi")
        
        let blur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        view.backgroundColor = .clear
//        view.backgroundColor = UIColor(white: 0, alpha: 0)
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
    }
    
    
}

extension ForecastVC{
    private func fetchForecastWeather(byCity city: String){
        manager.fetchLocationData(city: city) { (result) in
            self.handleResult(result)
        }
    }

    private func handleResult(_ result: Result<GeocodingResponse, Error>){
        switch result {
        case .success(let forecast):
            self.updateView(with: forecast)
        case .failure:
            self.handleError()
        }
    }

    private func handleError(){
        Loaf("Error", state: .info , location: .bottom, sender: self).show()
    }

    private func updateView(with forecast: GeocodingResponse){
        let cell = ForecastCollectionViewCell()
        let dailyForecast = forecast.forecastWeather.daily
        cell.dateLabel.text = dailyForecast.first?.dt.toString()
        cell.tempLabel.text = dailyForecast.first?.temp.day.toString()
        cell.conditionLabel.text = dailyForecast.first?.weather.first?.description
//        cell.conditionImage.image =
        print("SUCCESS")
    }
}


extension ForecastVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ForecastCollectionViewCell
        
        cell.dateLabel.text = "Friday"
        cell.tempLabel.text = "19"
        cell.conditionLabel.text = "Cloudy"
        cell.conditionImage.image = UIImage(named: "imCloud")
        cell.backgroundColor = UIColor.white
        cell.layer.cornerRadius = 20
        cell.conditionImage.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        cell.conditionImage.layer.shadowOffset = CGSize(width: 2, height: 2)
        cell.conditionImage.layer.shadowRadius = 2.5
        cell.conditionImage.layer.shadowOpacity = 0.3
        
        return cell
    }
    
    
}
