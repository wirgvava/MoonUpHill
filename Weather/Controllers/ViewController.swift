//
//  ViewController.swift
//  Weather
//
//  Created by Konstantine Tsirgvava on 11.02.23.
//

import UIKit
import CoreLocation
import CoreMotion
import Lottie
import Loaf

class ViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - Constants & Variables
    let motionManager = CMMotionManager()
    static var cityName = ""
    static var lat: Double = 0
    static var lon: Double = 0
    override var prefersStatusBarHidden: Bool { return true }
    private let weatherManager = WeatherManager()
    weak var delegate:  WeatherViewControllerDelegate?
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()

    //MARK: - Outlets
    @IBOutlet weak var searchBtnHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet weak var conditionBackground: UIImageView!
    @IBOutlet weak var texFieldStroke: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var animationView: LottieAnimationView!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAnimation()
        setupGestures()
        texFieldStroke.isHidden = true
        textField.isHidden = true
        self.textField.delegate = self
        fetchWeather(byCity: "Tbilisi")
        DispatchQueue.main.async {
            ViewController.lat = self.locationManager.location?.coordinate.latitude ?? 0
            ViewController.lon = self.locationManager.location?.coordinate.longitude ?? 0
            self.weatherManager.fetchForecast()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        motionManager.stopAccelerometerUpdates()
    }

    //MARK: - Actions
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        requestLocation()
        locationAnimation()
    }
    @IBAction func searchBtnTapped(_ sender: UIButton) {
        searchAction()
    }
    @IBAction func detailedForecastBtnTapped(_ sender: UIButton) {
        presentDetailedForecast()
    }
    
    //MARK: - Methods
    private func requestLocation(){
        let manager = CLLocationManager()
        switch manager.authorizationStatus{
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        default:
            promptForLocationPermision()
        }
    }
    
    private func searchAction(){
        if textField.isHidden == true {
            searchBarAnimation()
        } else {
            guard let query = textField.text, !query.isEmpty else {
                Loaf("City cannot be empty. Please try again!", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .right, sender: self).show()
                texFieldStroke.shake()
                return }
            handleSearch(city: query)
            dismissSearchBar()
            textField.text = ""
        }
    }
    
    private func presentDetailedForecast(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let forecastPresentationController = storyboard.instantiateViewController(withIdentifier: "detailedForecast") as! DetailedForecastVC
        self.present(forecastPresentationController, animated: true, completion: nil)
    }
  
    private func searchBarAnimation(){
        searchBtnHorizontalConstraint.constant = (textField.frame.maxX / 2) - 5
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        searchButton.isHidden = false
        texFieldStroke.isHidden = false
        textField.isHidden = false
        textField.becomeFirstResponder()
    }
    
    // Setup Lottie Animations --------------------------------------------------
    private func setupAnimation(){
        locationAnimation()
        birdsAnimation()
    }
    
    private func locationAnimation(){
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .repeat(1.5)
        animationView.play()
        motionManager.deviceMotionUpdateInterval = 0.01        // CoreMotion
        motionManager.startDeviceMotionUpdates(to: .main) { (data, error) in
            guard let data = data, error == nil else { return }
            let rotation = atan2(data.gravity.x, data.gravity.y) - .pi
            self.animationView.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
        }
    }
    
    private func birdsAnimation(){
        let birds = LottieAnimationView(name: "birds")
        birds.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: (view.frame.height) / 2)
        birds.contentMode = .scaleAspectFit
        birds.loopMode = .loop
        birds.play()
        conditionBackground.addSubview(birds)
    }
    // ---------------------------------------------------------------------------

    
    // Fetching eather by location -----------------------------------------------
    private func fetchWeather(byLocation location: CLLocation){
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        weatherManager.fetchWeather(lat: lat, lon: lon) {[weak self] (result) in
            guard let this = self else {return}
            this.handleResult(result)
        }
    }
    // Fetching weather by city name ---------------------------------------------
    private func fetchWeather(byCity city: String){
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
            ViewController.cityName = model.cityName
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.view.endEditing(true)
        searchAction()
        return true
    }
    
}



//MARK: - Search
extension ViewController {
    private func handleSearch(city: String){
        view.endEditing(true)
        weatherManager.fetchWeather(byCity: city) { [weak self] (result) in
            guard let this = self else {return}
            switch result{
            case .success(let model):
                this.handleSearchSuccess(model: model)
            case .failure(let error):
                Loaf(error.localizedDescription, state: .error, location: .top, presentingDirection: .left, dismissingDirection: .right, sender: self!).show()
                print("Error at SearchBar")
            }
        }
    }
    
    private func handleSearchSuccess(model: WeatherModel){
        DispatchQueue.main.async{ [weak self] in
            self?.delegate?.didUpdateWeatherFromSearch(model: model)
            self?.updateView(with: model)
        }
    }
}


//MARK: - Location
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


//MARK: - Gesture to dismiss SearchBar
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

