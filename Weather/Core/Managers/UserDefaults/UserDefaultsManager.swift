//
//  UserDefaultsManager.swift
//  Weather
//
//  Created by Konstantine Tsirgvava on 05.03.24.
//

import Foundation

class UserDefaultsManager {
    
    static let shared =  UserDefaultsManager()
    
    enum Key: String {
        case lat
        case lng
        case nameOfCity
        case widgetCity
        case widgetTemp
        case widgetBG
        case widgetCondition
        case firstSelected
    }
    
    // - Save
    func save(_ value: Any, for key: Key){
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    // - Get
    func getString(from key: Key) -> String? {
        return UserDefaults.standard.string(forKey: key.rawValue)
    }
    
    func getDouble(from key: Key) -> Double {
        return UserDefaults.standard.double(forKey: key.rawValue)
    }
    
    func getBool(from key: Key) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }
    
    // - (Save / Get) - AppGroups
    func saveAppGroupDefaults(_ value: Any?, for key: Key){
        guard let appGroups = Bundle.main.infoDictionary?["APP_GROUP"] as? String else { return }
        guard let defaults = UserDefaults(suiteName: appGroups) else { return }
        defaults.set(value, forKey: key.rawValue)
        defaults.synchronize()
    }
    
    func getAppGroupDefaultsString(from key: Key) -> String? {
        guard let appGroups = Bundle.main.infoDictionary?["APP_GROUP"] as? String else { return ""}
        guard let defaults = UserDefaults(suiteName: appGroups) else { return ""}
        return defaults.string(forKey: key.rawValue)
    }
    
    func getAppGroupDefaultsInt(from key: Key) -> Int? {
        guard let appGroups = Bundle.main.infoDictionary?["APP_GROUP"] as? String else { return 0}
        guard let defaults = UserDefaults(suiteName: appGroups) else { return 0}
        return defaults.integer(forKey: key.rawValue)
    }
}
