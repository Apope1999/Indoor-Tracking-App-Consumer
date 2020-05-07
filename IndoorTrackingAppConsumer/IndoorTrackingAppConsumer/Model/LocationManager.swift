//
//  LocationManager.swift
//  IndoorTrackingAppConsumer
//
//  Created by Apostolos Pezodromou on 7/5/20.
//  Copyright © 2020 Apostolos Pezodromou. All rights reserved.
//

import Foundation
import CoreLocation

struct LocationManager {
    var locationManager: CLLocationManager = CLLocationManager()
    
    func requestCurrentLocationStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
}
