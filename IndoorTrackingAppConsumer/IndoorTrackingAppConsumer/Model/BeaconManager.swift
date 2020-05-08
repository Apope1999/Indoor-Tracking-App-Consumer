//
//  BeaconManager.swift
//  IndoorTrackingAppConsumer
//
//  Created by Apostolos Pezodromou on 8/5/20.
//  Copyright © 2020 Apostolos Pezodromou. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

protocol BeaconManagerDelegate {
    func didUpdateRegions(_ beaconManager: BeaconManager, regions: [String])
    func startRanging(_ beaconManager: BeaconManager)
    func stopRanging(_ beaconManager: BeaconManager)
    func didDeleteProduct(_ beaconManager: BeaconManager)
    func didToggleLiveMode(_ beaconManager: BeaconManager, liveMode: Bool)
    func didFail()
}

class BeaconManager {
    
    let regionConstraint: CLBeaconIdentityConstraint?
    var regions: [Region] = []
    var shelves: [Shelf] = []
    var closestShelves: [String] = []
    var db = Firestore.firestore()
    var delegate: BeaconManagerDelegate?
    var liveMode: Bool?
    
    
    init() {
        let proximityUUID = UUID(uuidString:"98374d0a-fa8f-43ab-968b-88eaf83c6e4c")
        
        if let uuid = proximityUUID {
            regionConstraint = CLBeaconIdentityConstraint(uuid: uuid)
        } else {
            regionConstraint = nil
        }
    }
    
    
    
    func getRegion(minor: CLBeaconMinorValue, major: CLBeaconMajorValue) -> Region? {
        for region in regions {
            if region.minor == minor && region.major == major {
                return region
            }
        }
        return nil
    }
    
    func getShelf(id: String) -> Shelf? {
        return nil
    }
    
    func updateRegionOrder(regions: [CLBeacon]) {
        if regions.isEmpty { return }
        closestShelves.removeAll(keepingCapacity: false)
        for beacon in regions {
            if let minor = CLBeaconMinorValue(exactly: beacon.minor), let major = CLBeaconMajorValue(exactly: beacon.major) {
                print(self.regions)
                if let existingRegion = getRegion(minor: minor, major: major) {
                    print("Existing region \(existingRegion)")
                    for shelf in existingRegion.shelves {
                        closestShelves.append(shelf)
                        print("I registered a region")
                    }
                }
            } else {
                delegate?.didFail()
                return
            }
        }
        
        delegate?.didUpdateRegions(self, regions: closestShelves)
    }
    
    func requestRegionsWithNoPermission() {
        closestShelves.removeAll(keepingCapacity: false)
        for region in regions {
            closestShelves.append(contentsOf: region.shelves)
        }
        
        delegate?.didUpdateRegions(self, regions: closestShelves)
    }
    
    func toggleLiveMode() {
        guard let live = liveMode else { return }
        
        if liveMode! {
            liveMode = false
            delegate?.stopRanging(self)
            requestRegionsWithNoPermission()
            delegate?.didToggleLiveMode(self, liveMode: live)
        } else {
            liveMode = true
            delegate?.startRanging(self)
            delegate?.didToggleLiveMode(self, liveMode: live)
        }
    }
}

//MARK: - Update Local Model
extension BeaconManager {
    func addNewRegion(regionId: String, minor: CLBeaconMinorValue, major: CLBeaconMajorValue, shelves: [String]) {
        let tempRegion = Region(id: regionId, minor: minor, major: major, shelves: shelves)
        regions.append(tempRegion)
    }
    
    func addNewShelf(shelfId: String, products: [String]) {
        let tempShelf = Shelf(id: shelfId, products: products)
        shelves.append(tempShelf)
    }
}

//MARK: - Firebase Functions
extension BeaconManager {
    func loadRegionsFromFirebaseListener() -> ListenerRegistration {
        return db.collection(K.FStore.Regions.regions).addSnapshotListener { (documentSnapshot, err) in
            if let error = err {
                print(error)
            } else {
                self.regions = []
                for document in documentSnapshot!.documents {
                    let id = document.documentID
                    let data = document.data()
                    
                    self.addNewRegion(regionId: id, minor: data[K.FStore.Regions.minor] as! CLBeaconMinorValue, major: data[K.FStore.Regions.major] as! CLBeaconMajorValue, shelves: data[K.FStore.Regions.shelves] as! [String])
                    print(self.regions)
                }
            }
        }
        
    }
    
    func loadShelvesFromFirebaseListener() -> ListenerRegistration {
        return db.collection(K.FStore.Shelves.shelves).addSnapshotListener { (documentSnapshot, err) in
            if let error = err {
                print(error)
            } else {
                self.shelves = []
                for document in documentSnapshot!.documents {
                    let id = document.documentID
                    let data = document.data()
                    
                    self.addNewShelf(shelfId: id, products: data[K.FStore.Shelves.products] as! [String])
                }
            }
        }
    }
    
    func deleteProductFromFirebase(withName productName: String, from shelfName: String) {
        let shelvesCol = db.collection(K.FStore.Shelves.shelves).document(shelfName)
        
        shelvesCol.updateData([
            K.FStore.Shelves.products: FieldValue.arrayRemove([productName])
        ])
        
        db.collection(K.FStore.Products.products).document(productName).delete() { err in
            if let error = err {
                print(error)
                self.delegate?.didFail()
                return
            }
        }
        
        delegate?.didDeleteProduct(self)
    }
}

//MARK: - Deprecated Methods
extension BeaconManager {
    func loadRegionsFromFirebase() {
        db.collection(K.FStore.Regions.regions).getDocuments { (querySnapshot, err) in
            if let error = err {
                print(error)
            } else {
                for document in querySnapshot!.documents {
                    let id = document.documentID
                    let data = document.data()
                    
                    self.addNewRegion(regionId: id, minor: data[K.FStore.Regions.minor] as! CLBeaconMinorValue, major: data[K.FStore.Regions.major] as! CLBeaconMajorValue, shelves: data[K.FStore.Regions.shelves] as! [String])
                }
            }
        }
    }
    
    func loadShelvesFromFirebase() {
        db.collection(K.FStore.Shelves.shelves).getDocuments { (querySnapshot, err) in
            if let error = err {
                print(error)
            } else {
                for document in querySnapshot!.documents {
                    let id = document.documentID
                    let data = document.data()
                    
                    self.addNewShelf(shelfId: id, products: data[K.FStore.Shelves.products] as! [String])
                }
            }
        }
    }
}
