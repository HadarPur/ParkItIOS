//
//  ParkingStatisticsViewController.swift
//  ParkItIOS
//
//  Created by Hadar Pur on 25/03/2019.
//  Copyright © 2019 Hadar Pur. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import GoogleMaps

protocol CallbackStatisticsData {
    func performQuery(streets: Array<Street>)
}

class ParkingStatisticsViewController: UIViewController, CallbackStatisticsData {
    
    @IBOutlet weak var mHourTextField: UITextField!
    @IBOutlet weak var mMapView: GMSMapView!

    private let mFirebaseSingleton = Firebase.shared
    let mLocationManager = CLLocationManager()

    var mData = Array<Array<String>>()
    var mHoursData = ["07:00","08:00","09:00","10:00","11:00","12:00","13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00","22:00","23:00","00:00","01:00","02:00","03:00","04:00","05:00","06:00"]
    
    var mStreetData = Array<String>()
    var mStreets = Array<Array<Street>>()

    var mCurrentLat = 0.0
    var mCurrentLong = 0.0
    
    var mPickerView : UIPickerView!
    var mChosenHourPos: Int!
    var mChosenStreet: String!
    var mChosenStreetPos: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true

        self.pickUp(mHourTextField)
        
        mStreets.append(mFirebaseSingleton.getStreets(index: 0))
        mStreets.append(mFirebaseSingleton.getStreets(index: 1))
        mStreets.append(mFirebaseSingleton.getStreets(index: 2))

        for i in 0..<mStreets[0].count {
            if (!mStreetData.contains(mStreets[0][i].street)) {
                mStreetData.append(mStreets[0][i].street)
            }
        }
    
        mData.append(mStreetData)
        mData.append(mHoursData)

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
            let title = "Current Location"

            setDestLocationOnTheMap(latitudeUser: self.mCurrentLat, longitudeUser: self.mCurrentLong, title: title)
        }
    }
    
    func pickUp(_ textField : UITextField) {
        
        // UIPickerView
        self.mPickerView = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.mPickerView.delegate = self
        self.mPickerView.dataSource = self
        self.mPickerView.backgroundColor = UIColor.white
        textField.inputView = self.mPickerView
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.backgroundColor = UIColor(red: 156/255, green: 184/255, blue: 252/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }
    
    //MARK:- Button
    @objc func doneClick() {
        self.view.endEditing(true)
    }
    
    @objc func cancelClick() {
        self.view.endEditing(true)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        _=self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchButtonClicked(_ sender: Any) {
        self.view.endEditing(true)
        
        guard let chosenPos = mChosenHourPos else {
            FuncUtils().showToast(msg: "Please choose street and hour")
            return
        }
        
        guard let chosenStreet = mChosenStreet else {
            FuncUtils().showToast(msg: "Please choose street and hour")
            return
        }
        
        FuncUtils().showAlertActivityIndicator(viewController: self ,msg: "Please wait a sec...")
        setLocationOnTheMap(pos: chosenPos, streetName: chosenStreet)
    }
    
    @IBAction func textFieldEditing(_ sender: TextField) {
        self.pickUp(sender)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func getTimeType(pos: Int) -> Int {
        var time: Int = 0
        
        if pos >= 0 && pos<=7 {
            time = 0
        }
        
        if pos >= 8 && pos<=15 {
            time = 2
        }
        
        if pos >= 16 && pos<=23 {
            time = 1
        }
        
        return time
    }
    
    func setDestLocationOnTheMap(latitudeUser: Double, longitudeUser: Double, title: String) {
        self.mMapView.clear()
        var fullAddress: String!
        
        let latitude = latitudeUser
        let longitude = longitudeUser
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15)
        let userLocetion = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let loc: CLLocation = CLLocation(latitude:userLocetion.latitude, longitude: userLocetion.longitude)
        let marker = GMSMarker(position: userLocetion)
        
        if (latitude != 0 && longitude != 0) {
            StreetLocation().findAddressByLocation(location: loc) { (address) in
                marker.title = title
                switch(title) {
                case "Destination":
                    marker.icon = GMSMarker.markerImage(with: UIColor.magenta)
                    fullAddress = self.mChosenStreet + " st, Bat Yam"
                    
                    break
                case "Current Location":
                    marker.icon = GMSMarker.markerImage(with: UIColor.red)
                    fullAddress = address
                    
                    break
                default:
                    marker.icon = GMSMarker.markerImage(with: UIColor.red)
                }
                
                marker.snippet = fullAddress
            }
  
            self.mMapView.animate(to: camera)
            marker.map = self.mMapView
        }
    }
    
    func setLocationOnTheMap(pos: Int, streetName: String) {
        
        let hourType = getTimeType(pos: pos)
        let chosenStreet = mStreets[0][mChosenStreetPos]
        
        let lat = Double(chosenStreet.lat)!
        let lng = Double(chosenStreet.lng)!
        
        let title = "Destination"
        self.setDestLocationOnTheMap(latitudeUser: lat, longitudeUser: lng, title: title)
        
        CalaDistance().calculateDistances(streets: self.mStreets[hourType], street: chosenStreet, view: self, callback: self)
    }
    
    func performQuery(streets: Array<Street>) {
        for i in 0..<streets.count {
            setMarker(street: streets[i])
        }
        FuncUtils().hideAlertActivityIndicator(viewController: self)
    }
    
    func setMarker(street: Street) {
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
        
        marker.map = self.mMapView
    }
    
    func getStatus(street: Street) -> Int {
        let occupacy = Double(street.rate)!
        var status = 0
        
        if ((occupacy >= 0.0) && (occupacy*100 < 25.0)) { status = 0 }
        
        if ((occupacy >= 25.0) && (occupacy < 50.0)) { status = 1 }
        
        if ((occupacy >= 50.0) && (occupacy < 75.0)) { status = 2 }
        
        if ((occupacy >= 75.0) && (occupacy <= 100.0)) { status = 3 }
        
        return status
    }
}

extension ParkingStatisticsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return mData[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let street =  mData[0][pickerView.selectedRow(inComponent: 0)]
        let hour = mData[1][pickerView.selectedRow(inComponent: 1)]
        
        mChosenStreet = street
        mChosenStreetPos = pickerView.selectedRow(inComponent: 0)
        mChosenHourPos = pickerView.selectedRow(inComponent: 1)
        mHourTextField.text = street + " - " + hour
    }

}
