//
//  MainMenuViewController.swift
//  IndoorTrackingAppConsumer
//
//  Created by Apostolos Pezodromou on 8/5/20.
//  Copyright © 2020 Apostolos Pezodromou. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    @IBOutlet weak var topCardView: UIView!
    @IBOutlet weak var bottomCardView: UIView!
    @IBOutlet weak var liveViewButton: UIButton!
    @IBOutlet weak var searchViewButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        topCardView.layer.cornerRadius = 10
        bottomCardView.layer.cornerRadius = 10
        liveViewButton.layer.cornerRadius = 10
        searchViewButton.layer.cornerRadius = 10
    }
    
    @IBAction func liveViewButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.Segues.goToLiveView, sender: self)
    }
    
    @IBAction func searchViewButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.Segues.goToSearchView, sender: self)
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
