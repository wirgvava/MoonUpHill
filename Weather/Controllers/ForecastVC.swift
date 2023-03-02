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

class ForecastVC: UIViewController, UISheetPresentationControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override var sheetPresentationController: UISheetPresentationController?{
        presentationController as? UISheetPresentationController
    }
//    let manager = WeatherManager()
    let motionManager = CMMotionManager()


    override func viewDidLoad() {
        super.viewDidLoad()
     
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        motionManager.stopAccelerometerUpdates()
    }
    
    
}

extension ForecastVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ForecastCollectionViewCell
        
        cell.dateLabel.text = "Friday"
        cell.tempLabel.text = "19°C"
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
