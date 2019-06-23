//
//  ParkingSearchViewController.swift
//  ParkItIOS
//
//  Created by Hadar Pur on 25/03/2019.
//  Copyright © 2019 Hadar Pur. All rights reserved.
//

import UIKit


class ParkingSearchViewController: UIViewController {
    private let mFirebaseSingleton = Firebase.shared
    let mDistData = ["500 m", "1000 m", "1500 m", "2000 m"]
    
    var mPickerView : UIPickerView!
    
    var mStreetData = Array<String>()
    var mStreets = Array<Array<Street>>()
    
    var mDest: String!
    var mDist: Int!
    var mDestPos: Int!
    
    @IBOutlet weak var mDestTextField: TextField!
    @IBOutlet weak var mDistanceTextField: TextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true

        mStreets.append(mFirebaseSingleton.getStreets(index: 0))
        mStreets.append(mFirebaseSingleton.getStreets(index: 1))
        mStreets.append(mFirebaseSingleton.getStreets(index: 2))
        
        for i in 0..<mStreets[0].count {
            if (!mStreetData.contains(mStreets[0][i].street)) {
                mStreetData.append(mStreets[0][i].street)
            }
        }
        
        mDestTextField.delegate = self
        mDistanceTextField.delegate = self
        
        self.pickUp(mDestTextField)
        self.pickUp(mDistanceTextField)
        
        observerToSwipe()
    }
    
    func pickUp(_ textField : UITextField) {
        
        // UIPickerView
        self.mPickerView = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.mPickerView.backgroundColor = UIColor.white
        textField.inputView = self.mPickerView

        self.mPickerView.delegate = self
        self.mPickerView.dataSource = self
        
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
    
    
    @IBAction func mSearchButtonClicked(_ sender: Any) {
        guard let chosenDest = mDest else {
            FuncUtils().showToast(msg: "Please choose street")
            return
        }
        
        guard let chosenDist = mDist else {
            FuncUtils().showToast(msg: "Please choose distance from the parking place")
            return
        }
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let resultViewController = storyBoard.instantiateViewController(withIdentifier: "ParkingResultsViewController") as? ParkingResultsViewController
        
        guard resultViewController != nil else {
            return
        }
        
        let street = mStreets[0][mDestPos]
        
        resultViewController?.mDist = Double(chosenDist)
        resultViewController?.mDestinationName = chosenDest
        resultViewController?.mDestinationStreet = street
        
        self.navigationController?.pushViewController(resultViewController!, animated: true)
    }
}

extension ParkingSearchViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if mDestTextField.isFirstResponder{
            return mStreetData.count
        } else if mDistanceTextField.isFirstResponder{
            return mDistData.count
        }
        return 0
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if mDestTextField.isFirstResponder{
            return mStreetData[row]
        } else if mDistanceTextField.isFirstResponder{
            return mDistData[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if mDestTextField.isFirstResponder{
            let dest = mStreetData[row]
            mDestTextField.text = dest
            
            mDest = dest
            mDestPos = pickerView.selectedRow(inComponent: 0)
            
        } else if mDistanceTextField.isFirstResponder{
            let dist = mDistData[row]
            mDistanceTextField.text = dist
            
            mDist = Int(dist.split(separator: " ")[0])
        }
    }
}

extension ParkingSearchViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.mPickerView?.reloadAllComponents()
    }
}

