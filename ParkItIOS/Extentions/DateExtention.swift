//
//  DateExtention.swift
//  ParkItIOS
//
//  Created by Hadar Pur on 03/04/2019.
//  Copyright © 2019 Hadar Pur. All rights reserved.
//

import Foundation
import UIKit

// took from https://stackoverflow.com/questions/25533147/get-day-of-week-using-nsdate
extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}
