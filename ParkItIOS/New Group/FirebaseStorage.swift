//
//  FirebaseStorage.swift
//  ParkItIOS
//
//  Created by Hadar Pur on 27/03/2019.
//  Copyright © 2019 Hadar Pur. All rights reserved.
//

import Foundation
import FirebaseDatabase
import UIKit

public class FirebaseStorage {
    
    struct Street {
        var cars: String
        var rate: Double
        var sensor: Int
        var streetName: String
    }
    
    static let shared = FirebaseStorage()

    let mFunctions = FuncUtils()
    let NUM_OF_HOURS : Int = 3

    var mRef : DatabaseReference!
    var mData : Array<Street> = Array()
    var mDayHours: Array<Array<Street>> = Array()
    
    //init array
    func initAll() {
        for _ in 0..<NUM_OF_HOURS {
            mDayHours.append(mData)
        }
    }
    
    //return streets on specific time
    func getStreets(index: Int) -> Array<Street> {
        return mDayHours[index]
    }
    
    //gets all data
    func getData() -> Array<Array<Street>> {
        return mDayHours
    }
    
    //read the data from the firebase
    func readData(callback: @escaping () -> ()) {
        self.mRef = Database.database().reference()

        self.mRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let iterator = snapshot.children
            while let child = iterator.nextObject() as? DataSnapshot {

                print(child);
            }
            callback()
        }) { (error) in
            print(error.localizedDescription)
        }
    }

}

