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
    let mFunctions = FuncUtils()

    struct defaultsKeys {
        static let long = "longKey"
        static let lat = "latKey"
    }
    
    @IBOutlet weak var mMapView: GMSMapView!
    @IBOutlet weak var mLastLocationLabel: UILabel!
    @IBOutlet weak var mGoogleMapLocationButton: UIButton!
    @IBOutlet weak var mGoogleMapRouteButton: UIButton!
    
    var parkingLat = 0.0
    var parkingLong = 0.0
    
    let mLocationManager = CLLocationManager()
    var mCurrentLat = 0.0
    var mCurrentLong = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true

        self.mLocationManager.delegate = self
        self.mLocationManager.requestWhenInUseAuthorization()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        mLastLocationLabel.lineBreakMode = .byWordWrapping
        mLastLocationLabel.numberOfLines = 3
        
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
        let defaults = UserDefaults.standard
        defaults.set(mCurrentLong, forKey: defaultsKeys.long)
        defaults.set(mCurrentLat, forKey: defaultsKeys.lat)
    }
    
    @IBAction func findButtonClicked(_ sender: Any) {
        let defaults = UserDefaults.standard

        if let long = defaults.string(forKey: defaultsKeys.long) {
            parkingLong = Double(long)!
        }
        if let lat = defaults.string(forKey: defaultsKeys.lat) {
            parkingLat = Double(lat)!
        }
        
        setLocationOnTheMap(latitudeUser: parkingLat, longitudeUser: parkingLong, titleUser: "Parking Location")
    }
    
    @IBAction func resetButtonClicked(_ sender: Any) {
        setMyLocationOnTheMap(latitudeUser: self.mCurrentLat, longitudeUser: self.mCurrentLong)
    }
    
    
    @IBAction func navigateViaGoogleMapsButtonClicked(_ sender: Any) {
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps:")!) {
            UIApplication.shared.open(URL(string:"comgooglemaps://?saddr=\(parkingLat),\(parkingLong)&daddr=\(mCurrentLat),\(mCurrentLong)&directionsmode=walking")!, options: [:], completionHandler: nil)
        } else {
            mFunctions.showToast(msg: "Can't open GoogleMaps App")
        }
    }
    
    @IBAction func seeLocationViaGoogleMapsButtonClicked(_ sender: Any) {
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps:")!) {
            UIApplication.shared.open(URL(string:
                "comgooglemaps://?center=\(mCurrentLat),\(mCurrentLong).975866&zoom=14")!, options: [:], completionHandler: nil)
        } else {
            mFunctions.showToast(msg: "Can't open GoogleMaps App")
        }
    }
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            print("Swipe Right")
            _=self.navigationController?.popViewController(animated: true)
        }
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
