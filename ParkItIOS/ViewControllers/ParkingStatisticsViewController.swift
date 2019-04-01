//
//  ParkingStatisticsViewController.swift
//  ParkItIOS
//
//  Created by Hadar Pur on 25/03/2019.
//  Copyright © 2019 Hadar Pur. All rights reserved.
//

import UIKit

class ParkingStatisticsViewController: UIViewController {
    var hoursData = [["Pick a street"],["Pick hour","07:00","08:00","09:00","10:00","11:00","12:00","13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00","22:00","23:00","00:00","01:00","02:00","03:00","04:00","05:00","06:00"]]
    
    var mPickerView : UIPickerView!

    @IBOutlet weak var mHourTextField: UITextField!
    
    var mParkingLat = 0.0
    var mParkingLong = 0.0
    
    var mCurrentLat = 0.0
    var mCurrentLong = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true

        observerToSwipe()
        
        self.pickUp(mHourTextField)
        mHourTextField.text = self.hoursData[0][0] + " - " + self.hoursData[1][0]
    }
    
    func pickUp(_ textField : UITextField){
        
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
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
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
    
    @IBAction func navigateViaGoogleMapsButtonClicked(_ sender: Any) {
        GoogleMapsUtils().navigateWithGoogleMaps(parkingLat: mParkingLat, parkingLong: mParkingLong, currentLat: mCurrentLat, currentLong: mCurrentLong)
    }
    
    @IBAction func searchButtonClicked(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func textFieldEditing(_ sender: TextField) {
        self.pickUp(sender)
    }
    
    @IBAction func seeLocationViaGoogleMapsButtonClicked(_ sender: Any) {
        GoogleMapsUtils().locateWithGoogleMaps(currentLat: mCurrentLat, currentLong: mCurrentLong)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension ParkingStatisticsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hoursData[component].count

    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return hoursData[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let street =  hoursData[0][pickerView.selectedRow(inComponent: 0)]
        let hour = hoursData[1][pickerView.selectedRow(inComponent: 1)]
        mHourTextField.text =   street + " - " + hour
    }
}
