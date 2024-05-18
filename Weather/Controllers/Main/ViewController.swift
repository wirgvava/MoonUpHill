//
//  ViewController.swift
//  Weather
//
//  Created by Konstantine Tsirgvava on 11.02.23.
//

import UIKit
import Lottie
import WidgetKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - Constants & Variables
    let currentDate = Date()
    let calendar = Calendar.current
    static var forecast = [Daily]()
    static var weatherModel: WeatherModel?
    override var prefersStatusBarHidden: Bool { return true }
    private let weatherManager = WeatherManager()
    private var locationManager: LocationManager!
    
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
        let city = UserDefaultsManager.shared.getString(from: .nameOfCity) ?? "Tbilisi"
        cityLabel.text = city
        self.fetchWeather(byCity: city)
        self.cacheForecast()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CoreMotionAnimations.stopAccelerometerUpdates()
    }
    
    //MARK: - Actions
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        locationManager.requestLocation(on: self)
        CoreMotionAnimations.locationAnimation(animView: animationView)
    }
    
    @IBAction func searchBtnTapped(_ sender: UIButton) {
        searchAction()
    }
    
    @IBAction func detailedForecastBtnTapped(_ sender: UIButton) {
        presentDetailedForecast()
    }
    
    //MARK: - Methods
    private func configure(){
        setLocationManager()
        setupAnimation()
        setupGestures()
        texFieldStroke.isHidden = true
        textField.isHidden = true
        textField.delegate = self
    }
    
    private func setLocationManager(){
        locationManager = LocationManager(viewController: self)
    }
    
    private func searchAction(){
        if textField.isHidden == true {
            searchBarAnimation()
        } else {
            guard let query = textField.text, !query.isEmpty else {
                show(message: "City cannot be empty. Please try again!", state: .error)
                texFieldStroke.shake()
                return }
            UserDefaultsManager.shared.save(query, for: .nameOfCity)
            handleSearch(city: query)
            dismissSearchBar()
            textField.text = ""
        }
    }
    
    private func presentDetailedForecast(){
        guard ViewController.weatherModel != nil else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let forecastPresentationController = storyboard.instantiateViewController(withIdentifier: "detailedForecast") as! DetailedForecastVC
        AppAnalytics.logEvents(with: .opened_forecast, paramName: nil, paramData: nil)
        self.present(forecastPresentationController, animated: true, completion: nil)
    }
    
    // Setup Animations --------------------------------------------------
    private func setupAnimation(){
        CoreMotionAnimations.locationAnimation(animView: animationView)
        LottieAnimations.birdsAnimation(on: conditionBackground)
    }
    
    private func searchBarAnimation(){
        UIView.animate(withDuration: 0.3) {
            self.searchBtnHorizontalConstraint.constant = (self.textField.frame.maxX / 2) - 5
            self.view.layoutIfNeeded()
        }
        searchButton.isHidden = false
        texFieldStroke.isHidden = false
        textField.isHidden = false
        textField.becomeFirstResponder()
    }
    
    private func updateView(with model: WeatherModel){
        ViewController.weatherModel = model
        temperatureLabel.text = model.temp.toString().appending("°C")
        conditionLabel.text = model.conditionDescription
        cityLabel.text = model.cityName
        checkNightCondition(with: model)
        LottieAnimations.animate(background: conditionBackground, with: model)
        
        // Save App Groups UserDefaults
        UserDefaultsManager.shared.save(model.cityName, for: .nameOfCity)
        UserDefaultsManager.shared.saveAppGroupDefaults(model.cityName, for: .widgetCity)
        UserDefaultsManager.shared.saveAppGroupDefaults(model.temp, for: .widgetTemp)
        UserDefaultsManager.shared.saveAppGroupDefaults(model.conditionBackground, for: .widgetBG)
        
        WidgetCenter.shared.reloadTimelines(ofKind: "WeatherWidget")
        AppAnalytics.logEvents(with: .location, paramName: .city, paramData: model.cityName)
    }
    
    private func checkNightCondition(with model: WeatherModel){
        var isNight = false
        if let currentHour = calendar.dateComponents([.hour], from: currentDate).hour {
            isNight = currentHour > 20 || currentHour < 5 ? true : false
        }
        
        let conditionBG: UIImage = isNight ? UIImage(named: "night")! : UIImage(named: model.conditionBackground)!
        conditionBackground.image = conditionBG
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.view.endEditing(true)
        searchAction()
        return true
    }
}

//MARK: - Handle Network Responses
extension ViewController {
    func fetchWeather(lat: Double, lng: Double){
        weatherManager.fetchWeather(lat: lat, lng: lng) {[weak self] (result) in
            guard let this = self else { return }
            this.handleResult(result)
        }
    }
    
    func fetchForecast(lat: Double, lng: Double){
        weatherManager.fetchForecast(lat: lat, lon: lng) { [weak self] (result) in
            guard let this = self else { return }
            switch result {
            case .success(let daily):
                ViewController.forecast = daily
                
                let conditionImg = daily.first?.weather.first?.conditionImage
                UserDefaultsManager.shared.saveAppGroupDefaults(conditionImg, for: .widgetCondition)
            case .failure(let error):
                this.show(message: error.localizedDescription, state: .error)
            }
        }
    }
    
    private func cacheForecast(){
        let lat = UserDefaultsManager.shared.getDouble(from: .lat)
        let lng = UserDefaultsManager.shared.getDouble(from: .lng)
        fetchForecast(lat: lat, lng: lng)
    }
    
    private func fetchWeather(byCity city: String){
        weatherManager.fetchWeather(byCity: city) { [weak self](result) in
            guard let this = self else {return}
            this.handleResult(result)
        }
    }
    
    private func handleSearch(city: String){
        view.endEditing(true)
        weatherManager.fetchWeather(byCity: city) { [weak self] (result) in
            guard let this = self else {return}
            switch result{
            case .success(let model):
                this.updateView(with: model)
                this.locationManager.handleFromSearch(with: city)
            case .failure(let error):
                this.show(message: error.localizedDescription, state: .error)
            }
        }
    }
    
    private func handleResult(_ result: Result<WeatherModel, Error>){
        switch result {
        case .success(let model):
            updateView(with: model)
        case .failure:
            show(message: "We are waiting for permission.", state: .info)
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
        UIView.animate(withDuration: 0.3){
            self.searchBtnHorizontalConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        view.endEditing(true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == self.view
    }
}
