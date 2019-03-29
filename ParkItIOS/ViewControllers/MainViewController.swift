//
//  ViewController.swift
//  ParkItIOS
//
//  Created by Hadar Pur on 04/02/2019.
//  Copyright © 2019 Hadar Pur. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {
    let mFunctions = FuncUtils()
    private let mFirebaseSingleton = FirebaseStorage()
    
    let mLocationManager = CLLocationManager()
    
    var mCurrentLat: Double = 0
    var mCurrentLong: Double = 0
    
    var mFirstAsk = true
    var mIsNetworkEnabled: Bool?

    @IBOutlet weak var mFindParkingSpaceButton: RoundButton!
    @IBOutlet weak var mFindMyCarButton: RoundButton!
    @IBOutlet weak var mStatisticsButton: RoundButton!
    @IBOutlet weak var mAboutUsButton: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.mFunctions.showAlertActivityIndicator(viewController: self ,msg: "Please wait a sec...")
        
        self.mLocationManager.delegate = self

        mFirebaseSingleton.readData {
            self.mFunctions.hideAlertActivityIndicator(viewController: self)
            self.mLocationManager.requestWhenInUseAuthorization()

        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkParameters()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterForground(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func applicationDidEnterForground(_ notification: Notification) {
        self.mLocationManager.requestWhenInUseAuthorization()
        checkParameters()
    }
    
    func checkParameters(){
        guard Reachability.isLocationEnable() == true  && self.mFirstAsk == false else  {
            self.mAboutUsButton.isEnabled = true
            return
        }
        
        guard Reachability.isConnectedToNetwork() == true else {
            print("Internet Connection not Available!")
            self.mIsNetworkEnabled = false
            return
        }
        checkGPS()
        enableButtons()
        self.mIsNetworkEnabled = true
    }
    
    func enableButtons() {
        mFindParkingSpaceButton.isEnabled = true
        mFindMyCarButton.isEnabled = true
        mStatisticsButton.isEnabled = true
        mAboutUsButton.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self)

    }
    
    func disableButtons() {
        mFindParkingSpaceButton.isEnabled = false
        mFindMyCarButton.isEnabled = false
        mStatisticsButton.isEnabled = false
        mAboutUsButton.isEnabled = false
    }
    
    func checkGPS() {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            guard let currentLocation = self.mLocationManager.location else {
                return
            }
            self.mCurrentLat = currentLocation.coordinate.latitude
            self.mCurrentLong = currentLocation.coordinate.longitude
        }
    }
    
}

// extension for map view
extension MainViewController: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if mFirstAsk {
            AlertsHandler.showAlertMessage(title: "Location needed", message: "Please allow location to play", cancelButtonTitle: "OK")
        }
        
        self.mFirstAsk = false
        
        guard status == .authorizedWhenInUse else {
            disableButtons()
            return
        }
        
        self.mLocationManager.startUpdatingLocation()
        enableButtons()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.mLocationManager.stopUpdatingLocation()
    }
}

