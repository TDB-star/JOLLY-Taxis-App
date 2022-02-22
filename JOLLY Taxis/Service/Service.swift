//
//  Service.swift
//  JOLLY Taxis
//
//  Created by Tatiana Dmitrieva on 14.02.2022.
//

import Foundation
import Firebase
import CoreLocation
import GeoFire

let databaseUrl = "https://jolly-taxi-9dad6-default-rtdb.europe-west1.firebasedatabase.app"
let DB_REF = Database.database(url: databaseUrl).reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locationts")
let REF_TRIPS = DB_REF.child("trips")
class ServiceManager {
    
    static let shared = ServiceManager()
    
    
    private init() {}
    
    func fetchUserData(uid: String, completion: @escaping(User) -> Void) {
        DB_REF.child("users").child(uid).observeSingleEvent(of: .value) { snapsot in
            guard let value = snapsot.value as? NSDictionary else {return}
            let uid = snapsot.key
            let user = User(uid: uid, value)
            print("\(user.uid)")
            completion(user)
        }
    }
    
    func fetchDrivers(location: CLLocation, completion: @escaping(User) -> Void) {
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        
        REF_DRIVER_LOCATIONS.observe(.value) { (snapshot) in
            geofire.query(at: location, withRadius: 50).observe(.keyEntered, with: { (uid, location) in
                ServiceManager.shared.fetchUserData(uid: uid) { user in
                    var driver = user
                    driver.location = location
                    completion(driver)
                }
            })
        }
    }
    func uploadTrip(_ pickupCoordinates: CLLocationCoordinate2D, _ destinationCoordinates: CLLocationCoordinate2D, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let pickupArray = [pickupCoordinates.latitude, pickupCoordinates.longitude]
        let destinationArray = [destinationCoordinates.latitude, destinationCoordinates.longitude]
        
        let values = ["pickupCoordinates": pickupArray,
                      "destinationCoordinates": destinationArray,
                      "state": TripState.requested.rawValue] as [String: Any]
        REF_TRIPS.child(uid).updateChildValues(values, withCompletionBlock: completion)
    }
}

