//
//  ForecastCollectionViewCell.swift
//  Weather
//
//  Created by konstantine on 28.02.23.
//

import UIKit

class ForecastCollectionViewCell: UICollectionViewCell {
        
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var conditionImage: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    
    var selectedColor = CGColor(gray: 1, alpha: 1)
    
    override var isSelected: Bool {
        didSet {
            contentView.layer.masksToBounds = true
            contentView.layer.cornerRadius = 20
            contentView.layer.borderColor = selectedColor
            contentView.layer.borderWidth = isSelected ? 3 : 0
        }
    }
    
    func configure(with weather: Daily) {
        let date = Date(timeIntervalSince1970: TimeInterval(weather.dt))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        dateLabel.text = dateFormatter.string(from: date)
        tempLabel.text = "\(Int(weather.temp.day))°C"
        conditionLabel.text = weather.weather.first?.main
        conditionImage.image = UIImage(named: weather.weather.first?.conditionImage ?? "")
        backgroundColor = UIColor(white: 1, alpha: 0.5)
        layer.cornerRadius = 20
    }
}
