//
//  GoogleMapsUtils.swift
//  ParkItIOS
//
//  Created by Hadar Pur on 31/03/2019.
//  Copyright © 2019 Hadar Pur. All rights reserved.
//

import Foundation
import UIKit

class GoogleMapsUtils: NSObject {

    public func navigateWithGoogleMaps(parkingLat: Double, parkingLong: Double, currentLat: Double, currentLong: Double)  {
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps:")!) && (parkingLat != 0.0 || parkingLong != 0.0) {
            UIApplication.shared.open(URL(string:"comgooglemaps://?saddr=\(parkingLat),\(parkingLong)&daddr=\(currentLat),\(currentLong)&directionsmode=walking")!, options: [:], completionHandler: nil)
        } else {
            FuncUtils().showToast(msg: "Can't open GoogleMaps App")
        }
    }
    
    public func locateWithGoogleMaps(currentLat: Double, currentLong: Double) {
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps:")!) {
            UIApplication.shared.open(URL(string:
                "comgooglemaps://?center=\(currentLat),\(currentLong).975866&zoom=14")!, options: [:], completionHandler: nil)
        } else {
            FuncUtils().showToast(msg: "Can't open GoogleMaps App")
        }
    }

}
