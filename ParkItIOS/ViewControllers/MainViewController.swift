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
    private let mFirebaseSingleton = Firebase.shared
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
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        self.mLocationManager.delegate = self
        self.mLocationManager.requestWhenInUseAuthorization()
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
    
    @IBAction func findParkingSpaceButtonClicked(_ sender: UIButton) {
        disableButtons()
        sender.touch()
        
        let deadlineTime = DispatchTime.now() + .milliseconds(500)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let findParkingSpaceVC = storyBoard.instantiateViewController(withIdentifier: "findParkingSpaceVC") as? ParkingSearchViewController
        
        guard findParkingSpaceVC != nil else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            self.navigationController?.pushViewController(findParkingSpaceVC!, animated: true)
        })
        
    }
    
    @IBAction func findMyCarButtonClicked(_ sender: UIButton) {
        disableButtons()
        sender.touch()
        
        let deadlineTime = DispatchTime.now() + .milliseconds(500)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let findMyCarVC = storyBoard.instantiateViewController(withIdentifier: "findMyCarVC") as? FindMyCarViewConfroller
        
        guard findMyCarVC != nil else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            self.navigationController?.pushViewController(findMyCarVC!, animated: true)
        })
        
    }
    
    @IBAction func statisticsButtonClicked(_ sender: UIButton) {
        disableButtons()
        sender.touch()
        
        let deadlineTime = DispatchTime.now() + .milliseconds(500)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let statisticsVC = storyBoard.instantiateViewController(withIdentifier: "statisticsVC") as? ParkingStatisticsViewController
        
        guard statisticsVC != nil else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            self.navigationController?.pushViewController(statisticsVC!, animated: true)
        })
    }
    
    @IBAction func aboutUsButtonClicked(_ sender: UIButton) {
        disableButtons()
        sender.touch()
        
        let deadlineTime = DispatchTime.now() + .milliseconds(500)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let aboutUsVC = storyBoard.instantiateViewController(withIdentifier: "aboutUsVC") as? AboutUsViewController
        
        guard aboutUsVC != nil else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            self.navigationController?.pushViewController(aboutUsVC!, animated: true)
        })
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

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if mFirstAsk && status == .denied {
            FuncUtils().showEventsAcessDeniedAlert(viewController: self)
        }
        
        guard status == .authorizedWhenInUse else {
            disableButtons()
            return
        }
        
        FuncUtils().showAlertActivityIndicator(viewController: self ,msg: "Please wait a sec...")
        mFirebaseSingleton.readData {
            FuncUtils().hideAlertActivityIndicator(viewController: self)
        }
        
        self.mFirstAsk = false
        self.mLocationManager.startUpdatingLocation()
        enableButtons()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.mLocationManager.stopUpdatingLocation()
    }
}

