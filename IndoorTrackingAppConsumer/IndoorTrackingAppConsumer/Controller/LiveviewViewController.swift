//
//  LiveviewViewController.swift
//  IndoorTrackingAppConsumer
//
//  Created by Apostolos Pezodromou on 8/5/20.
//  Copyright © 2020 Apostolos Pezodromou. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase


class LiveviewViewController: UIViewController {
    
    @IBOutlet weak var productTableView: UITableView!
    
    var selectedProduct: String?
    var selectedProductSection: String?
    let locationManager = CLLocationManager()
    var beaconManager = BeaconManager()
    var regionListener: ListenerRegistration?
    var shelvesListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        productTableView.dataSource = self
        productTableView.register(UINib(nibName: K.Cells.productCell, bundle: nil), forCellReuseIdentifier: K.Cells.productCellID)
        productTableView.delegate = self
        
        navigationItem.title = "Products"
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        locationManager.requestAlwaysAuthorization()
        
        locationManager.delegate = self
        beaconManager.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        regionListener = beaconManager.loadRegionsFromFirebaseListener()
        shelvesListener = beaconManager.loadShelvesFromFirebaseListener()
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            beaconManager.requestRegionsWithNoPermission()
        case .authorizedAlways, .authorizedWhenInUse:
            beaconManager.liveMode = true
            startRanging(beaconManager)
        @unknown default:
            break
        }
        
        productTableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //regionListener?.remove()
        //shelvesListener?.remove()
        
        if let safeRegionConstraints = beaconManager.regionConstraint {
            locationManager.stopRangingBeacons(satisfying: safeRegionConstraints)
        }
    }
    
    
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            beaconManager.requestRegionsWithNoPermission()
        case .authorizedAlways, .authorizedWhenInUse:
            beaconManager.toggleLiveMode()
        @unknown default:
            break
        }
        
        productTableView.reloadData()
        print(beaconManager.closestShelves)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.showDetails {
            let productVC = segue.destination as! ProductDetailsViewController
            productVC.productString = selectedProduct
            productVC.productSection = selectedProductSection
        }
    }
}

//MARK: - Table View Data Source
extension LiveviewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let shelfName = beaconManager.closestShelves[section]
        let shelf = beaconManager.shelves.first(where: {$0.id == shelfName})
        return shelf?.products.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return beaconManager.closestShelves.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UITableViewHeaderFooterView()
        view.textLabel?.text = "\(beaconManager.closestShelves[section])"
        view.textLabel?.textColor = UIColor.white
        view.tintColor = UIColor.systemOrange
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.productCellID, for: indexPath) as! ProductCell
        
        let shelfName = beaconManager.closestShelves[indexPath.section]
        let shelf = beaconManager.shelves.first(where: {$0.id == shelfName})
        
        cell.productLabel.text = "\(shelf!.products[indexPath.row])"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}

//MARK: - Table View Delegate
extension LiveviewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? ProductCell
        
        //
        let sectionHeaderView = productTableView.headerView(forSection: indexPath.section)
        selectedProductSection = sectionHeaderView?.textLabel?.text
        //
        
        selectedProduct = cell?.productLabel.text
        performSegue(withIdentifier: K.Segues.showDetails, sender: self)
        cell?.isSelected = false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cell = tableView.cellForRow(at: indexPath) as? ProductCell
            let sectionHeaderView = productTableView.headerView(forSection: indexPath.section)
            
            selectedProductSection = sectionHeaderView?.textLabel?.text
            selectedProduct = cell?.productLabel.text
            
            beaconManager.deleteProductFromFirebase(withName: selectedProduct!, from: selectedProductSection!)
        }
    }
}

//MARK: - Location & Beacon Manager Delegate
extension LiveviewViewController: CLLocationManagerDelegate, BeaconManagerDelegate {
    func didToggleLiveMode(_ beaconManager: BeaconManager, liveMode: Bool) {
        return
    }
    
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        let knownBeacons = beacons.filter({$0.proximity != CLProximity.unknown})
        if knownBeacons.count > 0 {
            var closeBeacons: [CLBeacon] = []
            for beacon in knownBeacons {
                if 0.0...5.0 ~= beacon.accuracy {
                    closeBeacons.append(beacon)
                }
            }
            beaconManager.updateRegionOrder(regions: closeBeacons)
        }
    }
    
    func didUpdateRegions(_ beaconManager: BeaconManager, regions: [String]) {
        productTableView.reloadData()
    }
    
    func startRanging(_ beaconManager: BeaconManager) {
        if let safeRegionConstraints = beaconManager.regionConstraint {
            locationManager.startRangingBeacons(satisfying: safeRegionConstraints)
        }
    }
    
    func stopRanging(_ beaconManager: BeaconManager) {
        if let safeRegionConstraints = beaconManager.regionConstraint {
            locationManager.stopRangingBeacons(satisfying: safeRegionConstraints)
        }
    }
    
    func didDeleteProduct(_ beaconManager: BeaconManager) {
        productTableView.reloadData()
    }
    
    func didFail() {
        print("I failed")
    }
}

