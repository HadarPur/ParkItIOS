//
//  ParkingResultsViewController.swift
//  ParkItIOS
//
//  Created by Hadar Pur on 25/03/2019.
//  Copyright © 2019 Hadar Pur. All rights reserved.
//
import UIKit
import CoreLocation
import MapKit
import GoogleMaps

protocol CallbackParkingData {
    func performQuery(top10Streets: Array<Street>)
}

class ParkingResultsViewController: UIViewController, CallbackParkingData {
    
    private let mFirebaseSingleton = Firebase.shared
    let mLocationManager = CLLocationManager()

    var mDist: Double!
    var mDestinationName: String!
    var mDestinationStreet: Street!
    var mCurrentLat: Double!
    var mCurrentLong: Double!
    var mParkingLat: Double!
    var mParkingLong: Double!
    var mCurrentTitle: String!
    var mCurrentAddress: String!

    var mStreetsData = Array<Street>()
    var mStreets = Array<String>()
    
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var mMapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.mTableView.isScrollEnabled = true

        FuncUtils().showAlertActivityIndicator(viewController: self ,msg: "Please wait a sec...")

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
            self.mCurrentTitle = "Current Location"

            StreetLocation().findAddressByLocation(location: currentLocation) { (address) in
                self.mCurrentAddress = address
                self.setLocationOnTheMap(chosenStreet: self.mDestinationStreet)
            }
            
        }
    }
    
    func getTimeType(pos: Int) -> Int {
        var time: Int = 0
        
        if pos >= 0 && pos<=7 { time = 0 }
        if pos >= 8 && pos<=15 { time = 2 }
        if pos >= 16 && pos<=23 { time = 1 }
        
        return time
    }
    
    func setLocationOnTheMap(chosenStreet: Street) {
        self.mMapView.clear()

        let hour = Calendar.current.component(.hour, from: Date())
        let typeHour = getTimeType(pos: hour)
        let streets = mFirebaseSingleton.getStreets(index: typeHour)

        let lat = Double(chosenStreet.lat)!
        let lng = Double(chosenStreet.lng)!
        
        let title = "Destination"
        let address = self.mDestinationName + " st, Bat Yam"
        
        self.setDestLocationOnTheMap(latitudeUser: self.mCurrentLat, longitudeUser: self.mCurrentLong, title: self.mCurrentTitle, address: self.mCurrentAddress)
        
        self.setDestLocationOnTheMap(latitudeUser: lat, longitudeUser: lng, title: title, address: address)
    
        CalaDistance().calculateDistances(streets: streets, street: chosenStreet, view: self, radius: mDist, callback: self)
    }
    
    func setLocationWithChosenParkingSpaceOnTheMap(chosenStreet: Street, chosenParkingSpace: Street) {
        self.mMapView.clear()
        
        let lat = Double(chosenStreet.lat)!
        let lng = Double(chosenStreet.lng)!
        
        let title = "Destination"
        let address = chosenStreet.street + " st, Bat Yam"
        
        let latP = Double(chosenParkingSpace.lat)!
        let lngP = Double(chosenParkingSpace.lng)!
        
        let titleP = "Parking Space"
        let addressP = chosenParkingSpace.street + " st, Bat Yam"
        
        self.setDestLocationOnTheMap(latitudeUser: self.mCurrentLat, longitudeUser: self.mCurrentLong, title: self.mCurrentTitle, address: self.mCurrentAddress)

        self.setDestLocationOnTheMap(latitudeUser: lat, longitudeUser: lng, title: title, address: address)
    
        self.setDestLocationOnTheMap(latitudeUser: latP, longitudeUser: lngP, title: titleP, address: addressP)
        
    }
    
    func setDestLocationOnTheMap(latitudeUser: Double, longitudeUser: Double, title: String, address: String) {
        var fullAddress: String!
        
        let latitude = latitudeUser
        let longitude = longitudeUser
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15)
        let userLocetion = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let marker = GMSMarker(position: userLocetion)
        
        if (latitude != 0 && longitude != 0) {
            
            switch(title) {
                case "Current":
                    marker.icon = GMSMarker.markerImage(with: UIColor.red)
                    break
                
                case "Parking Space":
                    marker.icon = GMSMarker.markerImage(with: UIColor.blue)
                    break

                case "Destination":
                    marker.icon = GMSMarker.markerImage(with: UIColor.magenta)
                    break
                
                default:
                    marker.icon = GMSMarker.markerImage(with: UIColor.red)
                    break
            }
            fullAddress = address
            marker.title = title

            marker.snippet = fullAddress

            self.mMapView.animate(to: camera)
            marker.map = self.mMapView
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        _=self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func navigateViaGoogleMapsButtonClicked(_ sender: Any) {
        GoogleMapsUtils().navigateWithGoogleMaps(parkingLat: mParkingLat, parkingLong: mParkingLong, currentLat: mCurrentLat, currentLong: mCurrentLong)
    }
    
    @IBAction func seeLocationViaGoogleMapsButtonClicked(_ sender: Any) {
        GoogleMapsUtils().locateWithGoogleMaps(currentLat: mCurrentLat, currentLong: mCurrentLong)
    }
    
    func performQuery(top10Streets: Array<Street>) {
        self.mStreetsData.removeAll()
        self.mStreets.removeAll()
        self.mTableView.reloadData()

        self.mStreetsData = top10Streets
        self.mTableView.beginUpdates()

        for street in self.mStreetsData {
            let occupacy = Double(street.rate)!

            let s: String = "Street name: \(street.street!)\nOccupation rate: \((occupacy*100).rounded()/100) %"

            self.mStreets.append(s)

            self.mTableView.insertRows(at: [IndexPath(row: self.mStreets.count-1, section: 0)], with: .automatic)
        }
        self.mTableView.endUpdates()
        print("Done reading streets\n")
        
        FuncUtils().hideAlertActivityIndicator(viewController: self)
    }
}

// extension for table view
extension ParkingResultsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mStreets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = mStreets[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "table") as! TableViewCell
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.text = row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.mParkingLat = Double(self.mStreetsData[indexPath.row].lat)
        self.mParkingLong = Double(self.mStreetsData[indexPath.row].lng)
        
        self.setLocationWithChosenParkingSpaceOnTheMap(chosenStreet: mDestinationStreet, chosenParkingSpace: self.mStreetsData[indexPath.row])
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
