//
//  Trip.swift
//  JOLLY Taxis
//
//  Created by Tatiana Dmitrieva on 21.02.2022.
//

import CoreLocation
import CoreText


enum TripState: Int {
    case requested = 0
    case accepted
    case inProgress
    case completed
}

struct Trip {
    var pickupCoordinates: CLLocationCoordinate2D!
    var destinationCoordinates: CLLocationCoordinate2D!
    let passengerUid: String
    var driverUid: String?
    var state: TripState!
    
    init(passangerUid: String, dictionary: [String: Any]) {
        self.passengerUid = passangerUid
        
        if let pickupCoordinates = dictionary["pickupCoordinates"] as? NSArray {
            guard let lat = pickupCoordinates[0] as?  CLLocationDegrees else { return }
            guard let long = pickupCoordinates[1] as? CLLocationDegrees else { return }
            self.pickupCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        if let destinationCoordinates = dictionary["destinationCoordinates"] as? NSArray {
            guard let lat = destinationCoordinates[0] as?  CLLocationDegrees else { return }
            guard let long = destinationCoordinates[1] as? CLLocationDegrees else { return }
            self.destinationCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        self.driverUid = dictionary["driverUid"] as?  String ?? ""
        
        if let state = dictionary["state"] as? Int {
            self.state = TripState(rawValue: state)
        }
    }
}

