//
//  CalaDistance.swift
//  ParkItIOS
//
//  Created by Hadar Pur on 27/03/2019.
//  Copyright © 2019 Hadar Pur. All rights reserved.
//

import Foundation
import MapKit
import GoogleMaps

protocol DistanceDelegate: class {
    func filterDistance(thArr: Array<FirebaseData.Street>)
}

class CalaDistance: DistanceDelegate {
    let NUM_OF_THREADS: Int = 1
    
    var mMap: GMSMapView!
    var mStreets = Array<FirebaseData.Street>()
    var mStreetsOnRadar = Array<FirebaseData.Street>()
    var mStreet: FirebaseData.Street!
    var mCount: Int = 0
    var mCurrentThread: Int = 0
    var mView: UIViewController!
    
    public func calculateDistances(map: GMSMapView ,streets: Array<FirebaseData.Street>, street: FirebaseData.Street, view: UIViewController) {
        self.mMap = map
        self.mStreets.append(contentsOf: streets)
        self.mStreet = street
        self.mView = view
        
        
        self.findNearByStreets(destLocLat: Double(mStreet.lat)!, destLocLng: Double(mStreet.lng)!, streets: self.mStreets)
    }
    
    func getStatus(street: FirebaseData.Street) -> Int {
        let occupacy = Double(street.rate)!
        var status = 0
        
        if ((occupacy >= 0.0) && (occupacy*100 < 25.0)) { status = 0 }
        
        if ((occupacy >= 25.0) && (occupacy < 50.0)) { status = 1 }
        
        if ((occupacy >= 50.0) && (occupacy < 75.0)) { status = 2 }
        
        if ((occupacy >= 75.0) && (occupacy <= 100.0)) { status = 3 }

        return status
    }
    
    func setMarker(street: FirebaseData.Street) {
        let occupacy = Double(street.rate)!

        let status = getStatus(street: street)
        let statusTypes = ["empty","available","occupied","full"]

        let streetName: String = street.street
        let address: String = streetName + " st, Bat Yam"
        
        let lat = Double(street.lat)!
        let lng = Double(street.lng)!
        
        let title = "\(statusTypes[status]) : \((occupacy*100).rounded()/100) %"
            
        let locetion = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let marker = GMSMarker(position: locetion)
            
        marker.title = title
        marker.snippet = "Location: \(address)"
            
        switch(status) {
        case 0:
            marker.icon = GMSMarker.markerImage(with: UIColor.cyan)
            break
        case 1:
            marker.icon = GMSMarker.markerImage(with: UIColor.green)
            break
        case 2:
            marker.icon = GMSMarker.markerImage(with: UIColor.orange)
            break
        case 3:
            marker.icon = GMSMarker.markerImage(with: UIColor.blue)
            break
        default:
            marker.icon = GMSMarker.markerImage(with: UIColor.red)
            break
        }
            
        marker.map = self.mMap
    }
    
    func findNearByStreets(destLocLat: Double, destLocLng: Double, streets: Array<FirebaseData.Street>) {
        DispatchQueue.main.async {
            let distClass = DistanceClass()
            distClass.initDistanceClass(streetsOld: streets, numOfThreads: self.NUM_OF_THREADS, destLocLat: destLocLat, destLocLng: destLocLng)
            distClass.calculate(cuttrntThread: self.mCurrentThread, completion: self.filterDistance(thArr:))
        }
    }
    
    func filterDistance(thArr: Array<FirebaseData.Street>) {
        mStreetsOnRadar.append(contentsOf: thArr)
        mCount += 1
        if mCount == NUM_OF_THREADS {
            for i in 0..<mStreetsOnRadar.count {
                setMarker(street: mStreetsOnRadar[i])
            }
            FuncUtils().hideAlertActivityIndicator(viewController: mView)
        }
    }
}
