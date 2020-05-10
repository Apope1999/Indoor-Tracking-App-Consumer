//
//  SearchviewViewController.swift
//  IndoorTrackingAppConsumer
//
//  Created by Apostolos Pezodromou on 9/5/20.
//  Copyright © 2020 Apostolos Pezodromou. All rights reserved.
//

import UIKit
import Firebase

class SearchviewViewController: UIViewController {
    
    @IBOutlet weak var productTableView: UITableView!
    
    var selectedProduct: String?
    var selectedProductSection: String?
    var beaconManager = BeaconManager()
    var regionListener: ListenerRegistration?
    var shelvesListener: ListenerRegistration?
    
    var searchProducts = [String]()
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        productTableView.dataSource = self
        productTableView.register(UINib(nibName: K.Cells.productCell, bundle: nil), forCellReuseIdentifier: K.Cells.productCellID)
        productTableView.delegate = self
        
        navigationItem.title = "Products"
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        beaconManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        regionListener = beaconManager.loadRegionsFromFirebaseListener()
        shelvesListener = beaconManager.loadShelvesFromFirebaseListener()
        
        beaconManager.liveMode = false
        beaconManager.requestRegionsWithNoPermission()
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        //MARK: - TODO Erase search field
        searching = false
        beaconManager.requestRegionsWithNoPermission()
    }
    
    // MARK: - Navigation
    //MARK: - TODO!!!
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
extension SearchviewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let shelfName = beaconManager.closestShelves[section]
        let shelf = beaconManager.shelves.first(where: {$0.id == shelfName})
        
        if searching {
            return searchProducts.count
           
        } else {
            return shelf?.products.count ?? 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searching {
            return 1
        } else {
            return beaconManager.closestShelves.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UITableViewHeaderFooterView()
        view.textLabel?.textColor = UIColor.white
        view.tintColor = UIColor.systemOrange
        if searching {
            view.textLabel?.text = "Results"
        } else {
            view.textLabel?.text = "\(beaconManager.closestShelves[section])"
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.productCellID, for: indexPath) as! ProductCell
        
        let shelfName = beaconManager.closestShelves[indexPath.section]
        let shelf = beaconManager.shelves.first(where: {$0.id == shelfName})
        
        if searching {
            cell.productLabel.text = searchProducts[indexPath.row]
        } else {
            cell.productLabel.text = "\(shelf!.products[indexPath.row])"
        }
        return cell
    }
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
    
    
}

//MARK: - Table View Delegate
extension SearchviewViewController: UITableViewDelegate {
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
}

extension SearchviewViewController: BeaconManagerDelegate {
    
    func didUpdateRegions(_ beaconManager: BeaconManager, regions: [String]) {
        productTableView.reloadData()
    }
    
    func startRanging(_ beaconManager: BeaconManager) {
        return
    }
    
    func stopRanging(_ beaconManager: BeaconManager) {
        return
    }
    
    func didDeleteProduct(_ beaconManager: BeaconManager) {
        productTableView.reloadData()
    }
    
    func didToggleLiveMode(_ beaconManager: BeaconManager, liveMode: Bool) {
        return
    }
    
    func didFail() {
        print("I failed")
    }
}

extension SearchviewViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchProducts.removeAll()
        for shelf in beaconManager.shelves {
            let products = shelf.products
            searchProducts.append(contentsOf: products.filter({$0.prefix(searchText.count) == searchText}))
            searching = true
            productTableView.reloadData()
        }
    }
}

