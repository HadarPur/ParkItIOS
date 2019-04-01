//
//  ParkingStatisticsViewController.swift
//  ParkItIOS
//
//  Created by Hadar Pur on 25/03/2019.
//  Copyright © 2019 Hadar Pur. All rights reserved.
//

import UIKit

class ParkingStatisticsViewController: UIViewController {
    var hoursData = ["Pick hour","07:00","08:00","09:00","10:00","11:00","12:00","13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00","22:00","23:00","00:00","01:00","02:00","03:00","04:00","05:00","06:00"]
    
    var mHoursViewPicker = UIPickerView()

    @IBOutlet weak var mStreetTextField: UITextField!
    @IBOutlet weak var mHourTextField: UITextField!
    
    var mParkingLat = 0.0
    var mParkingLong = 0.0
    
    var mCurrentLat = 0.0
    var mCurrentLong = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        // Connect data:
        self.mHoursViewPicker.delegate = self
        self.mHoursViewPicker.dataSource = self
        
        mHourTextField.inputView = mHoursViewPicker
        mHourTextField.text = hoursData[0]
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        _=self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func navigateViaGoogleMapsButtonClicked(_ sender: Any) {
        GoogleMapsUtils().navigateWithGoogleMaps(parkingLat: mParkingLat, parkingLong: mParkingLong, currentLat: mCurrentLat, currentLong: mCurrentLong)
    }
    
    @IBAction func searchButtonClicked(_ sender: Any) {
        self.view.endEditing(true)

    }
    
    @IBAction func textFieldEditing(_ sender: TextField) {
        sender.inputView = mHoursViewPicker
    }
    
    @IBAction func seeLocationViaGoogleMapsButtonClicked(_ sender: Any) {
        GoogleMapsUtils().locateWithGoogleMaps(currentLat: mCurrentLat, currentLong: mCurrentLong)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            print("Swipe Right")
            _=self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension ParkingStatisticsViewController: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hoursData.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return hoursData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        mHourTextField.text = hoursData[row]
    }
    
    
}
