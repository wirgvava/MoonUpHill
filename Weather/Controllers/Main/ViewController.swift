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
import WidgetKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - Constants & Variables
    let currentDate = Date()
    let calendar = Calendar.current
    let motionManager = CMMotionManager()
    static var forecast = [Daily]()
    static var weatherModel: WeatherModel?
    override var prefersStatusBarHidden: Bool { return true }
    private let weatherManager = WeatherManager()
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
    override func loadView() {
        super.loadView()
        cityLabel.text = UserDefaults.standard.string(forKey: "nameOfCity")
        self.fetchWeather(byCity: UserDefaults.standard.string(forKey: "nameOfCity") ?? "Tbilisi")
        self.cacheForecast()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        texFieldStroke.isHidden = true
        textField.isHidden = true
        textField.delegate = self
        setupAnimation()
        setupGestures()
        locationManager.requestWhenInUseAuthorization()
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
            UserDefaults.standard.set(query, forKey: "nameOfCity")
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

    // Fetching weather by location -----------------------------------------------
    private func fetchWeather(byLocation location: CLLocation){
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        weatherManager.fetchWeather(lat: lat, lon: lon) {[weak self] (result) in
            guard let this = self else { return }
            this.handleResult(result)
            let city = this.cityLabel.text
            UserDefaults.standard.set(city, forKey: "nameOfCity")
        }
    }
    
    private func fetchForecast(lat: Double, lng: Double){
        weatherManager.fetchForecast(lat: lat, lon: lng) { [weak self] (result) in
            guard let this = self else { return }
            switch result {
            case .success(let daily):
                ViewController.forecast = daily

                guard let appGroups = Bundle.main.infoDictionary?["APP_GROUP"] as? String else { return }
                if let defaults = UserDefaults(suiteName: appGroups) {
                    defaults.set(daily.first?.weather.first?.conditionImage, forKey: "widgetCondition")
                    defaults.synchronize()
                }
            case .failure(let error):
                Loaf(error.localizedDescription, sender: this).show()
            }
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
        ViewController.weatherModel = model
        temperatureLabel.text = model.temp.toString().appending("°C")
        conditionLabel.text = model.conditionDescription
        cityLabel.text = model.cityName
        checkNightCondition(with: model)
      
        // Save weather data in the main app
        guard let appGroups = Bundle.main.infoDictionary?["APP_GROUP"] as? String else { return }
        if let defaults = UserDefaults(suiteName: appGroups) {
            defaults.set(model.cityName, forKey: "widgetCity")
            defaults.set(model.temp, forKey: "widgetTemp")
            defaults.set(model.conditionBackground, forKey: "widgetBG")
            // Save other weather data as needed
            defaults.synchronize()
        }
        
        WidgetCenter.shared.reloadTimelines(ofKind: "WeatherWidget")
    }
    
    private func checkNightCondition(with model: WeatherModel){
        var isNight = false
        if let currentHour = calendar.dateComponents([.hour], from: currentDate).hour {
            isNight = currentHour > 20 || currentHour < 5 ? true : false
        }
        
        var conditionBG: UIImage = isNight ? UIImage(named: "night")! : UIImage(named: model.conditionBackground)!
        conditionBackground.image = conditionBG
       
        switch model.conditionId {
        case 200...599:
            nightConditionAnimation(isNight: isNight, name: "rain")
        case 600...699:
            nightConditionAnimation(isNight: isNight, name: "snow")
        default:
            return
        }
    }
    
    private func nightConditionAnimation(isNight: Bool, name: String) {
        let animation = LottieAnimationView(name: name)
        animation.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        animation.loopMode = .loop
        animation.contentMode = .scaleAspectFill
        animation.play()
        self.conditionBackground.addSubview(animation)
        self.conditionBackground.addSubview(animation)
    }
    
    private func cacheForecast(){
        if UserDefaults.standard.double(forKey: "lat") != 0.0 &&
            UserDefaults.standard.double(forKey: "lng") != 0.0 {
            let lat = UserDefaults.standard.double(forKey: "lat")
            let lng = UserDefaults.standard.double(forKey: "lng")
            fetchForecast(lat: lat, lng: lng)
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
                this.updateView(with: model)
                this.handleFromSearch(with: city)
            case .failure(let error):
                Loaf(error.localizedDescription, state: .error, location: .top, presentingDirection: .left, dismissingDirection: .right, sender: self!).show()
            }
        }
    }
}

//MARK: - Location
extension ViewController: CLLocationManagerDelegate {
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
            UserDefaults.standard.set(lat, forKey: "lat")
            UserDefaults.standard.set(lng, forKey: "lng")
            
            fetchWeather(byLocation: location)
            fetchForecast(lat: lat, lng: lng)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        handleError()
    }
    
    func handleFromSearch(with city: String){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(city) { (placemarks, error) in
            guard let placemarks = placemarks,
                  let placemark = placemarks.first,
                  let location = placemark.location else { return }
            
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            self.fetchForecast(lat: lat, lng: lng)
        }
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
