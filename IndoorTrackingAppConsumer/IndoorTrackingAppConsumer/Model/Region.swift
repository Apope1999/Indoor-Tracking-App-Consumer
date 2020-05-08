//
//  Region.swift
//  IndoorTrackingAppConsumer
//
//  Created by Apostolos Pezodromou on 8/5/20.
//  Copyright © 2020 Apostolos Pezodromou. All rights reserved.
//

import Foundation
import CoreLocation

struct Region {
    let id: String
    let minor: CLBeaconMinorValue
    let major: CLBeaconMajorValue
    
    var shelves: [String]
}
