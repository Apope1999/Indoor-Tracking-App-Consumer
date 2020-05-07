//
//  LocationConfirmationViewController.swift
//  IndoorTrackingAppConsumer
//
//  Created by Apostolos Pezodromou on 29/4/20.
//  Copyright © 2020 Apostolos Pezodromou. All rights reserved.
//

import UIKit
import Lottie
import CoreLocation

class LocationConfirmationViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var animatedView: AnimationView!
    var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager = CLLocationManager()
        
        locationManager?.delegate = self
    }
    

    @IBAction func allowButtonTapped(_ sender: UIButton) {
        locationManager?.requestAlwaysAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            didAuthorizeLocation()
        case .restricted, .denied:
            didNotAuthorizeLocation()
        case .notDetermined:
            return
        @unknown default:
            return
        }
    }
    
    func didAuthorizeLocation() {
        let checkMarkAnimation =  AnimationView(name: "19311-reskinned-checkmark")
        animatedView.contentMode = .scaleToFill
        self.animatedView.addSubview(checkMarkAnimation)
        checkMarkAnimation.frame = self.animatedView.bounds
        checkMarkAnimation.loopMode = .playOnce
        checkMarkAnimation.play { (finished) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func didNotAuthorizeLocation() {
        let crosskAnimation =  AnimationView(name: "4970-unapproved-cross")
        animatedView.contentMode = .scaleToFill
        self.animatedView.addSubview(crosskAnimation)
        crosskAnimation.frame = self.animatedView.bounds
        crosskAnimation.loopMode = .playOnce
        crosskAnimation.play { (finished) in
            let alert = UIAlertController(title: "Location Denied", message: "You can change this option from the settings page.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { action in
                if let url = URL.init(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))
            self.present(alert, animated: true)

        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
