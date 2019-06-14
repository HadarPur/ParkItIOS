//
//  FindMyCarViewConfroller.swift
//  ParkItIOS
//
//  Created by Hadar Pur on 25/03/2019.
//  Copyright © 2019 Hadar Pur. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import GoogleMaps

class FindMyCarViewConfroller: UIViewController , CLLocationManagerDelegate{
    let mLocationManager = CLLocationManager()
    
    @IBOutlet weak var mMapView: GMSMapView!
    @IBOutlet weak var mLastLocationLabel: UILabel!
    
    var mParkingLat = 0.0
    var mParkingLong = 0.0
    
    var mCurrentLat = 0.0
    var mCurrentLong = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true

        self.mLocationManager.delegate = self
        self.mLocationManager.requestWhenInUseAuthorization()
        
        observerToSwipe()
        checkGPS()
    }
    
    func checkGPS() {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            guard let currentLocation = self.mLocationManager.location else {
                return
            }
            self.mCurrentLat = currentLocation.coordinate.latitude
            self.mCurrentLong = currentLocation.coordinate.longitude
            setMyLocationOnTheMap(latitudeUser: self.mCurrentLat, longitudeUser: self.mCurrentLong)
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        CoreStorage().saveLocation(lat: mCurrentLat, long: mCurrentLong)
    }
    
    @IBAction func findButtonClicked(_ sender: Any) {
        (mParkingLong, mParkingLat) = CoreStorage().getLocation()
        
        setLocationOnTheMap(latitudeUser: mParkingLat, longitudeUser: mParkingLong, titleUser: "Parking Location")
    }
    
    @IBAction func resetButtonClicked(_ sender: Any) {
        setMyLocationOnTheMap(latitudeUser: self.mCurrentLat, longitudeUser: self.mCurrentLong)
    }
    
    @IBAction func navigateViaGoogleMapsButtonClicked(_ sender: Any) {
        GoogleMapsUtils().navigateWithGoogleMaps(parkingLat: mParkingLat, parkingLong: mParkingLong, currentLat: mCurrentLat, currentLong: mCurrentLong)
    }
    
    @IBAction func seeLocationViaGoogleMapsButtonClicked(_ sender: Any) {
        GoogleMapsUtils().locateWithGoogleMaps(currentLat: mCurrentLat, currentLong: mCurrentLong)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        _=self.navigationController?.popViewController(animated: true)
    }
    
    func setMyLocationOnTheMap(latitudeUser: Double, longitudeUser: Double) {
        self.mMapView.clear()

        let latitude = latitudeUser
        let longitude = longitudeUser
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 12)
        let userLocetion = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        let loc: CLLocation = CLLocation(latitude:userLocetion.latitude, longitude: userLocetion.longitude)
        let marker = GMSMarker(position: userLocetion)
        
        if (latitude != 0 && longitude != 0) {
            geocoder.reverseGeocodeLocation(loc, completionHandler: {(placemarks, error) in
                if (error != nil) {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                else {
                    marker.title = "Current Location"
                    let locationStreet = placemarks?[0]
                    let locName: String = locationStreet?.name ?? "null"
                    let locLocality: String = locationStreet?.locality ?? "null"
                    let address = locName+", "+locLocality
                    
                    marker.snippet = address
                    
                    self.mLastLocationLabel.text = "Current Location:\n" + address
                }
            })
            self.mMapView.animate(to: camera)
            marker.map = self.mMapView
        }
    }
    
    func setLocationOnTheMap(latitudeUser: Double, longitudeUser: Double, titleUser: String) {
        self.setMyLocationOnTheMap(latitudeUser: self.mCurrentLat, longitudeUser: self.mCurrentLong)

        let latitude = latitudeUser
        let longitude = longitudeUser
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 12)
        let userLocetion = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        let loc: CLLocation = CLLocation(latitude:userLocetion.latitude, longitude: userLocetion.longitude)
        let marker = GMSMarker(position: userLocetion)
        
        let imageView = UIImageView(image: UIImage(named: "carmarker.png"))
        imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)

        marker.iconView = imageView
        marker.title = titleUser
        
        geocoder.reverseGeocodeLocation(loc, completionHandler: {(placemarks, error) in
            if (error != nil) {
                print("reverse geodcode fail: \(error!.localizedDescription)")
            }
            else {
                let locationStreet = placemarks?[0]
                let locName: String = locationStreet?.name ?? "null"
                let locLocality: String = locationStreet?.locality ?? "null"
                
                let address = locName+", "+locLocality
                
                marker.snippet = address
                self.mLastLocationLabel.text = "Parking Location:\n" + address
            }
        })
        
        self.mMapView.animate(to: camera)
        marker.map = self.mMapView
    }
}
