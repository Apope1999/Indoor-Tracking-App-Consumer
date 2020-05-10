//
//  Constants.swift
//  IndoorTrackingAppConsumer
//
//  Created by Apostolos Pezodromou on 7/5/20.
//  Copyright © 2020 Apostolos Pezodromou. All rights reserved.
//

import Foundation


struct K {
    struct Segues {
        static let logOn = "login"
        static let register = "register"
        static let locationConfirmation = "locationConfirm"
        static let goMainMenu = "mainMenu"
        static let goToLiveView = "goLiveView"
        static let goToSearchView = "goSearchView"
        static let showDetails = "showDetails"
    }
    
    struct Cells {
        static let productCellID = "ReusableProductCell"
        static let productCell = "ProductCell"
    }
    
    struct FStore {
        struct Regions {
            static let regions = "regions"
            static let minor = "minor"
            static let major = "major"
            static let shelves = "shelves"
        }
        
        struct Shelves {
            static let shelves = "shelves"
            static let products = "products"
        }
        
        struct Products {
            static let products = "products"
            static let description = "description"
            static let retailPrice = "retailPrice"
            static let wholeSalePrice = "wholesalePrice"
        }
    }
}
