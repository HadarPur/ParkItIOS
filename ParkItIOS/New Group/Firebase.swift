//
//  FirebaseStorage.swift
//  ParkItIOS
//
//  Created by Hadar Pur on 27/03/2019.
//  Copyright © 2019 Hadar Pur. All rights reserved.
//

import Foundation
import UIKit

public class Firebase {
    static let shared = Firebase()
    let fbData = FirebaseData()
    
    //return streets on specific time
    func getStreets(index: Int) -> Array<FirebaseData.Street> {
        return fbData.getCloudDataArray(index: index)
    }
    
    //gets all data
    func getData() -> Array<Array<FirebaseData.Street>> {
        return fbData.getCloudDataAllArrays()
    }
    
    //read the data from the firebase
    func readData(callback: @escaping () -> ()) {
        fbData.cofig(callback: callback)
    }

}

