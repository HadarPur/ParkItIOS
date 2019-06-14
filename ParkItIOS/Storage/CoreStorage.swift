//
//  CoreStorage.swift
//  ParkItIOS
//
//  Created by Hadar Pur on 03/04/2019.
//  Copyright © 2019 Hadar Pur. All rights reserved.
//

import Foundation
import CoreLocation

class CoreStorage {
    struct defaultsKeys {
        static let long = "longKey"
        static let lat = "latKey"
    }
    
    func saveLocation(lat: Double, long: Double) {
        let defaults = UserDefaults.standard
        defaults.set(long, forKey: defaultsKeys.long)
        defaults.set(lat, forKey: defaultsKeys.lat)
    }
    
    func getLocation() -> (Double, Double) {
        let defaults = UserDefaults.standard
        var locationLong: Double?
        var locationLat: Double?
        
        if let long = defaults.string(forKey: defaultsKeys.long) {
            locationLong = Double(long)!
        }
        if let lat = defaults.string(forKey: defaultsKeys.lat) {
            locationLat = Double(lat)!
        }
        
        return (locationLong ?? 0, locationLat ?? 0)
    }
    
}
