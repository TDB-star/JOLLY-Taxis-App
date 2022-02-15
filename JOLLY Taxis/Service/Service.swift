//
//  Service.swift
//  JOLLY Taxis
//
//  Created by Tatiana Dmitrieva on 14.02.2022.
//

import Foundation
import Firebase

let databaseUrl = "https://jolly-taxi-9dad6-default-rtdb.europe-west1.firebasedatabase.app"
let DB_REF = Database.database(url: databaseUrl).reference()
let REF_USERS = DB_REF.child("users")

class ServiceManager {
    
    static let shared = ServiceManager()
    let currentUid = Auth.auth().currentUser?.uid
    
    private init() {}
    
    func fetchUserData(completion: @escaping(User) -> Void) {
        
        DB_REF.child("users").child(currentUid ?? "").observeSingleEvent(of: .value) { snapsot in
            guard let value = snapsot.value as? NSDictionary else {return}
           // let userName = value["fullname"] as? String
            let user = User(value)
            completion(user)
            print("DEBUG: \(user.fullname)")
        }
    }
}
