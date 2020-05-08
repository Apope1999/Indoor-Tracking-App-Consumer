//
//  Product.swift
//  IndoorTrackingAppConsumer
//
//  Created by Apostolos Pezodromou on 8/5/20.
//  Copyright © 2020 Apostolos Pezodromou. All rights reserved.
//

import Foundation

struct Product {
    var name: String
    var description: String
    var retailPrice: Double
    var wholesalePrice: Double
    
    init(name: String, description: String, retailPrice: Double, wholesalePrice: Double) {
        self.name = name
        self.description = description
        self.retailPrice = retailPrice
        self.wholesalePrice = wholesalePrice
    }
}
