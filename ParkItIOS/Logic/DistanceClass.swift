//
//  DistanceClass.swift
//  ParkItIOS
//
//  Created by Hadar Pur on 11/06/2019.
//  Copyright © 2019 Hadar Pur. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import GoogleMaps

class DistanceClass {
    
    var mStreetsOld = Array<FirebaseData.Street>()
    var mStreetsNew = Array<FirebaseData.Street>()
    var mNumOfThreads: Int!
    var mRadius: Double!
    var mDestLocLat: Double!
    var mDestLocLng: Double!
    var mEnter: Bool!
    var mCounter: Int!

    func initDistanceClass(streetsOld: Array<FirebaseData.Street>, numOfThreads: Int, destLocLat: Double, destLocLng: Double) {
        mNumOfThreads = numOfThreads
        mStreetsOld.append(contentsOf: streetsOld)
        mDestLocLat = destLocLat
        mDestLocLng = destLocLng
        mRadius = 500
    }

    func initDistanceClass(streetsOld: Array<FirebaseData.Street>, numOfThreads: Int, destLocLat: Double, destLocLng: Double, radius: Double) {
        mNumOfThreads = numOfThreads
        mStreetsOld.append(contentsOf: streetsOld)
        mDestLocLat = destLocLat
        mDestLocLng = destLocLng
        mRadius = radius
    }
    
    func calculate(cuttrntThread: Int, completion: @escaping (_ newStreets: Array<FirebaseData.Street>)-> Void) {
        let destLocLat = mDestLocLat!
        let destLocLng = mDestLocLng!

        for i in 0..<mStreetsOld.count {
            
            let street = mStreetsOld[i]
            
            let streetLocLat: Double = Double(street.lat)!
            let streetLocLng: Double = Double(street.lng)!
            
            let numOfCars: Int = Int(street.cars)!
            let numOfSensors: Int = Int(street.sensors)!
            let radius: Double = Double(self.mRadius)
            
            let walkDist: Double = StreetLocation().calcWalkingDistance(lat1: destLocLat, lon1: destLocLng, lat2: streetLocLat, lon2: streetLocLng)
            
            print("walkDist == \(walkDist) mRadius == \(radius) numOfCars == \(numOfCars) numOfSensors ==\(numOfSensors)")
            
            if (walkDist <= radius) && (numOfCars < numOfSensors) {
                print("add one more")
                self.mStreetsNew.append(street)
            }
        }
        completion(self.mStreetsNew)
    }
}
