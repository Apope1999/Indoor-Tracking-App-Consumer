//
//  ProductTrackingViewController.swift
//  IndoorTrackingAppConsumer
//
//  Created by Apostolos Pezodromou on 10/5/20.
//  Copyright © 2020 Apostolos Pezodromou. All rights reserved.
//

import UIKit
import CoreLocation

class ProductTrackingViewController: UIViewController {
    
    var productName: String?
    var minorMajorArray: [UInt16]?
    let locationManager = CLLocationManager()
    @IBOutlet weak var metersLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = productName
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        locationManager.delegate = self
        let proximityUUID = UUID(uuidString:"98374d0a-fa8f-43ab-968b-88eaf83c6e4c")!
        let regionConstraint = CLBeaconIdentityConstraint(uuid: proximityUUID)
        locationManager.startRangingBeacons(satisfying: regionConstraint)
        
        metersLabel.minimumScaleFactor = 0.5
    }
}

//MARK: - Location & Beacon Manager Delegate
extension ProductTrackingViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        for beacon in beacons {
            let minor = minorMajorArray?.first
            let major = minorMajorArray?.last
            if UInt16(truncating: beacon.minor) == minor && UInt16(truncating: beacon.major) == major {
                switch beacon.accuracy {
                case -1:
                    break
                case 0..<5:
                    metersLabel.text = "Less than 5 meters"
                case 5..<10:
                    metersLabel.text = "Less than 10 meters"
                case 10..<20:
                    metersLabel.text = "~15 meters"
                case 20..<30:
                    metersLabel.text = "~25 meters"
                default:
                    break
                }
            }
        }
    }
}
