//
//  ForecastVC.swift
//  Weather
//
//  Created by konstantine on 21.02.23.
//

import UIKit
import CoreMotion
import SwiftyJSON
import Loaf
import CoreLocation
import Alamofire

class ForecastVC: UIViewController, UISheetPresentationControllerDelegate {
    
    // MARK: - Oulets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Variables & Constants
    let weatherManager = WeatherManager()
    let forecast = WeatherManager.forecastWeather
    override var sheetPresentationController: UISheetPresentationController?{
        presentationController as? UISheetPresentationController
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherManager.fetchForecast()
        print("lat: \(ViewController.lat) lon: \(ViewController.lon)")
     
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
    }
}



extension ForecastVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return forecast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ForecastCollectionViewCell
        
        let forecast = forecast[indexPath.row]
        cell.configure(with: forecast)
        return cell
    }
}
