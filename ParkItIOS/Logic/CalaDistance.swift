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
    func filterDistanceForStatistics(thArr: Array<Street>)
    func filterDistanceForParkingSpace(thArr: Array<Street>)
}

class CalaDistance: DistanceDelegate {
    var mStreets = Array<Street>()
    var mTop5Streets = Array<String>()

    var mStreet: Street!
    var mView: UIViewController!
    var mRadius: Double!
    var mCallbackStatistics: CallbackStatisticsData!
    var mCallbackParking: CallbackParkingData!

    public func calculateDistances(streets: Array<Street>, street: Street, view: UIViewController, callback: CallbackStatisticsData) {
        self.mStreets.append(contentsOf: streets)
        self.mStreet = street
        self.mView = view
        self.mCallbackStatistics = callback

        self.findNearByStreetsForStatistics(destLocLat: Double(mStreet.lat)!, destLocLng: Double(mStreet.lng)!, streets: self.mStreets)
    }
    
    public func calculateDistances(streets: Array<Street>, street: Street, view: UIViewController, radius: Double, callback: CallbackParkingData) {
        self.mStreets.append(contentsOf: streets)
        self.mStreet = street
        self.mView = view
        self.mRadius = radius
        self.mCallbackParking = callback
        
        self.findNearByStreetsForParkingSapce(destLocLat: Double(mStreet.lat)!, destLocLng: Double(mStreet.lng)!, streets: self.mStreets, radius: self.mRadius)
    }
    
    func findNearByStreetsForStatistics(destLocLat: Double, destLocLng: Double, streets: Array<Street>) {
        let distClass = DistanceClass()
        distClass.initDistanceClass(streetsOld: streets, destLocLat: destLocLat, destLocLng: destLocLng)
        distClass.calculate(completion: self.filterDistanceForStatistics(thArr:))
    }
    
    func findNearByStreetsForParkingSapce(destLocLat: Double, destLocLng: Double, streets: Array<Street>, radius: Double) {
        let distClass = DistanceClass()
        distClass.initDistanceClass(streetsOld: streets, destLocLat: destLocLat, destLocLng: destLocLng, radius: radius)
        distClass.calculate(completion: self.filterDistanceForParkingSpace(thArr:))
    }
    
    func filterDistanceForStatistics(thArr: Array<Street>) {
        var streetsOnRadar = Array<Street>()
        streetsOnRadar.append(contentsOf: thArr)
        mCallbackStatistics.performQuery(streets: streetsOnRadar)
    }
    
    func filterDistanceForParkingSpace(thArr: Array<Street>) {
        var streetsOnRadar = Array<Street>()
        streetsOnRadar.append(contentsOf: thArr)

        for i in 0..<streetsOnRadar.count {
            streetsOnRadar[i].utilityValue = utilityFunction(street: streetsOnRadar[i],raduis: mRadius)
        }
        
        let sortedStreets = streetsOnRadar.sorted()
        var top10StreetsData = Array<Street>()

        for i in 0..<10 {
            top10StreetsData.append(sortedStreets[i])
        }
        
        mCallbackParking.performQuery(top10Streets: top10StreetsData)
    }
    
    func utilityFunction(street: Street ,raduis: Double) -> Double {
        let numOfCars: Int = Int(street.cars)!
        let numOfSensors: Int = Int(street.sensors)!
        let occupacy: Double = Double(street.rate)!

        let walkingDistanceNorm: Double = calculateNorm(realVal: raduis, maxVal: 2000)
        let carsRate: Double = calculateNorm(realVal: Double(numOfCars), maxVal: Double(numOfSensors))
        let occupacyRate: Double = calculateNorm(realVal: occupacy, maxVal: 100)

        let utilVal: Double = (10 * occupacyRate) + (5 * carsRate) + (2 * walkingDistanceNorm)
        
        return utilVal
    }
}
