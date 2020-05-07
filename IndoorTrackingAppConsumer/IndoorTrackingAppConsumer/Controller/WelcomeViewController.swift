//
//  WelcomeViewController.swift
//  IndoorTrackingAppConsumer
//
//  Created by Apostolos Pezodromou on 29/4/20.
//  Copyright © 2020 Apostolos Pezodromou. All rights reserved.
//

import UIKit
import Lottie

class WelcomeViewController: UIViewController {
    var locationManager: LocationManager?

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        performSegueWithPermissionCheck(forIdentifier: K.Segues.logOn)
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        performSegueWithPermissionCheck(forIdentifier: K.Segues.register)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager = LocationManager()
    }
    
    //MARK: - Navigation
    func performSegueWithPermissionCheck(forIdentifier segueString: String) {
        switch locationManager?.requestCurrentLocationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            performSegue(withIdentifier: segueString, sender: self)
        case .denied, .none, .restricted, .notDetermined:
            performSegue(withIdentifier: K.Segues.locationConfirmation, sender: self)
        default:
            return
        }
    }
}
