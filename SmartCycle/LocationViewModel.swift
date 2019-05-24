//
//  LocationViewModel.swift
//  SmartCycle
//
//  Created by Yannick Mael Raoumbe on 24/04/2019.
//  Copyright © 2019 ME. All rights reserved.
//

import Foundation
import CoreLocation

class CurrentLocation: Codable {
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    let latitude: Double
    let longitude: Double
    let date: Date
    let dateString: String
    let description: String
    
    var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(_ location: CLLocationCoordinate2D, date: Date, descriptionString: String) {
        
        latitude =  location.latitude
        longitude =  location.longitude
        self.date = date
        dateString = CurrentLocation.dateFormatter.string(from: date)
        description = descriptionString
    }
}
