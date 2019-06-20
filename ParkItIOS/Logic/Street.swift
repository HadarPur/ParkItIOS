//
//  Street.swift
//  ParkItIOS
//
//  Created by Hadar Pur on 19/06/2019.
//  Copyright © 2019 Hadar Pur. All rights reserved.
//

import Foundation

struct Street: Decodable {
    var cars: String!
    var lat: String!
    var lng: String!
    var rate: String!
    var sensors: String!
    var street: String!
    
    var utilityValue: Double?
}

func calculateNorm(realVal: Double, maxVal: Double) -> Double {
    return realVal/maxVal
}

extension Street: Comparable {
    static func < (lhs: Street, rhs: Street) -> Bool {
        return (lhs.utilityValue?.isLess(than: rhs.utilityValue!))!
    }
    
    static func == (lhs: Street, rhs: Street) -> Bool {
        return (lhs.utilityValue?.isEqual(to: rhs.utilityValue!))!
    }
    
    static func > (lhs: Street, rhs: Street) -> Bool {
        return (rhs.utilityValue?.isLess(than: lhs.utilityValue!))!
    }
}
