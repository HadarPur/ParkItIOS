//
//  StreetLocation.swift
//  ParkItIOS
//
//  Created by Hadar Pur on 12/06/2019.
//  Copyright © 2019 Hadar Pur. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import GoogleMaps

class StreetLocation {
    
    func findStreetLocation(address: String, completion: @escaping (_ location: CLLocation?)-> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location else {
                print("address: \(address)")
                print("location Error: \(error?.localizedDescription ?? "")")
                return
            }
            completion(location)
        }
    }
    
    func deg2rad(deg:Double) -> Double {
        return deg * .pi / 180
    }
    
    func rad2deg(rad:Double) -> Double {
        return rad * 180.0 / .pi
    }
    
    func calcWalkingDistance(lat1:Double, lon1:Double, lat2:Double, lon2:Double) -> Double {
        let theta = lon1 - lon2
        var dist = sin(deg2rad(deg: lat1)) * sin(deg2rad(deg: lat2)) + cos(deg2rad(deg: lat1)) * cos(deg2rad(deg: lat2)) * cos(deg2rad(deg: theta))
        dist = acos(dist)
        dist = rad2deg(rad: dist)
        dist = dist * 60 * 1.1515
        
        dist = dist * 1.609344
        
        return dist*1000
    }
}
