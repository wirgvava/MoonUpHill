//
//  LocationManager.swift
//  Weather
//
//  Created by Konstantine Tsirgvava on 06.03.24.
//

import UIKit
import CoreLocation

class LocationManager: NSObject {
    
    fileprivate weak var viewController: ViewController!
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
//  MARK: - Init
    init(viewController: ViewController!) {
        self.viewController = viewController
        super.init()
        requestOnLoad()
    }
    
//  MARK: - Methods
    func requestOnLoad(){
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocation(on vc: UIViewController){
        let manager = CLLocationManager()
        switch manager.authorizationStatus{
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        default:
            promptForLocationPermision(vc: vc)
        }
    }
    
    func promptForLocationPermision(vc: UIViewController){
        let alert = UIAlertController(title: "Requares Location permision", message: "Whould you like to enable location permissions in Settings?", preferredStyle: .alert)
        let enableAction = UIAlertAction(title: "Go to Settings", style: .default){ _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {return}
            UIApplication.shared.open(settingsUrl)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(enableAction)
        alert.addAction(cancelAction)
        vc.present(alert, animated: true)
    }
}

//MARK: - Location
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .restricted, .denied, .notDetermined:
            locationManager.stopUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            manager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            UserDefaultsManager.shared.save(lat, for: .lat)
            UserDefaultsManager.shared.save(lng, for: .lng)
            
            viewController.fetchWeather(lat: lat, lng: lng)
            viewController.fetchForecast(lat: lat, lng: lng)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        viewController.show(message: "We are waiting for permission.", state: .info)
    }
}

extension LocationManager {
    func handleFromSearch(with city: String){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(city) { (placemarks, error) in
            guard let placemarks = placemarks,
                  let placemark = placemarks.first,
                  let location = placemark.location else { return }
            
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            self.viewController.fetchForecast(lat: lat, lng: lng)
        }
    }
}
