//
//  ViewController.swift
//  Weather
//
//  Created by konstantine on 11.02.23.
//

import UIKit
import Lottie
import Loaf
import CoreLocation
import CoreMotion

class ViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var searchBtnHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet weak var conditionBackground: UIImageView!
    @IBOutlet weak var texFieldStroke: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var locationButton: UIButton!
    
    // MARK: - Constants & Variables
    let motionManager = CMMotionManager()
    override var prefersStatusBarHidden: Bool { return true }
    private let weatherManager = WeatherManager()
    weak var delegate:  WeatherViewControllerDelegate?
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    static var lat: Double = 0
    static var lon: Double = 0
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        lottieAnimation()
        setupGestures()
        texFieldStroke.isHidden = true
        textField.isHidden = true
        DispatchQueue.main.async {
            ViewController.lat = self.locationManager.location?.coordinate.latitude ?? 0
            ViewController.lon = self.locationManager.location?.coordinate.longitude ?? 0
            self.weatherManager.fetchForecast()
        }
        self.textField.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        motionManager.stopAccelerometerUpdates()
    }

    // MARK: - Actions
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        switch CLLocationManager.authorizationStatus(){
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        default:
            promptForLocationPermision()
        }
    }
    
    @IBAction func searchBtnTapped(_ sender: UIButton) {
        searchAction()
    }
    
    @IBAction func forecastView(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let forecastPresentationController = storyboard.instantiateViewController(withIdentifier: "ForecastVC") as! ForecastVC
        self.present(forecastPresentationController, animated: true, completion: nil)
    }
    
    // MARK: - Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.view.endEditing(true)
        searchAction()
        return true
    }
    
    func searchAction(){
        if textField.isHidden == true {
            searchBarAnimation()
        } else {
            guard let query = textField.text, !query.isEmpty else {
                Loaf("City cannot be empty. Please try again!", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .right, sender: self).show()
                texFieldStroke.shake()
                return}
            handleSearch(city: query)
            dismissSearchBar()
            textField.text = ""
        }
    }
   
    func searchBarAnimation(){
        searchBtnHorizontalConstraint.constant = (textField.frame.maxX / 2) - 5
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        searchButton.isHidden = false
        texFieldStroke.isHidden = false
        textField.isHidden = false
        textField.becomeFirstResponder()
    }
    
    func lottieAnimation(){
        let lottieLocationButton = LottieAnimationView(name: "locationMarker")
        lottieLocationButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        lottieLocationButton.center = CGPoint(x: 25, y: 25)
        lottieLocationButton.contentMode = .scaleAspectFill
        myView.addSubview(lottieLocationButton)
        lottieLocationButton.play()
        lottieLocationButton.loopMode = .playOnce
        // CoreMotion
        motionManager.deviceMotionUpdateInterval = 0.01
        motionManager.startDeviceMotionUpdates(to: .main) { (data, error) in
            guard let data = data, error == nil else { return }
            
            let rotation = atan2(data.gravity.x,
                                 data.gravity.y) - .pi
            lottieLocationButton.transform =
            CGAffineTransform(rotationAngle: CGFloat(rotation))
        }
        
    }

    
    // Fetching Weather by Location & City -------------------------------------------
    private func fetchWeather(byLocation location: CLLocation){
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        weatherManager.fetchWeather(lat: lat, lon: lon) {[weak self] (result) in
            guard let this = self else {return}
            this.handleResult(result)
        }
    }
    
    private func fetchWeather(byCity city: String){
        weatherManager.fetchWeather(byCity: city) { [weak self](result) in
            guard let this = self else {return}
            this.handleResult(result)
        }
    }
    //---------------------------------------------------------------------------------
    
    private func handleResult(_ result: Result<WeatherModel, Error>){
        switch result {
        case .success(let model):
            updateView(with: model)
        case .failure:
            handleError()
        }
    }
    
    private func handleError(){
        Loaf("We are waiting for permission.", state: .info , location: .bottom, sender: self).show()
    }
    
    private func updateView(with model: WeatherModel){
        temperatureLabel.text = model.temp.toString().appending("°C")
        conditionLabel.text = model.conditionDescription
        conditionBackground.image = UIImage(named: model.conditionBackground)
        cityLabel.text = model.cityName
        DispatchQueue.main.async {
            ViewController.lat = model.lat
            ViewController.lon = model.lon
        }
    }
    
    private func promptForLocationPermision(){
        let alert = UIAlertController(title: "Requares Location permision", message: "Whould you like to enable location permissions in Settings?", preferredStyle: .alert)
        let enableAction = UIAlertAction(title: "Go to Settings", style: .default){ _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {return}
            UIApplication.shared.open(settingsUrl)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(enableAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
}



    // MARK: - Extensions

// Search----------------------------------------------------------------------------------------------
extension ViewController {
    func handleSearch(city: String){
        view.endEditing(true)
        weatherManager.fetchWeather(byCity: city) { [weak self] (result) in
            guard let this = self else {return}
            switch result{
            case .success(let model):
                this.handleSearchSuccess(model: model)
            case .failure(let error):
                Loaf(error.localizedDescription, state: .error, location: .top, presentingDirection: .left, dismissingDirection: .right, sender: self!).show()
            }
        }
    }
    
    func handleSearchSuccess(model: WeatherModel){
        DispatchQueue.main.async{ [weak self] in
            self?.delegate?.didUpdateWeatherFromSearch(model: model)
            self?.updateView(with: model)
        }
    }
}


// Location ------------------------------------------------------------------------------------
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            manager.stopUpdatingLocation()
            fetchWeather(byLocation: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        handleError()
    }
}


// Gesture for dismiss SearchBar ----------------------------------------------------------------
extension ViewController: UIGestureRecognizerDelegate {
    func setupGestures(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissSearchBar))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissSearchBar(){
        texFieldStroke.isHidden = true
        textField.isHidden = true
        searchBtnHorizontalConstraint.constant = 0
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
        view.endEditing(true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == self.view
    }
}

