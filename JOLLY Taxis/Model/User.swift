//
//  User.swift
//  JOLLY Taxis
//
//  Created by Tatiana Dmitrieva on 15.02.2022.
//

import Foundation
import CoreLocation

enum AccountType: Int {
    case passenger
    case driver
}

struct User {
    let uid: String
    let fullname: String
    let email: String
    var accountType: AccountType!
    var location: CLLocation?
    var homeLocation: String?
    var workLocation: String?
    
    init(uid: String, _ dictionary: NSDictionary) {
        self.uid = uid
        fullname = dictionary["fullname"] as? String ?? ""
        email = dictionary["email"] as? String ?? ""
        
        if let home = dictionary["homeLocation"] as? String {
            homeLocation = home
        }
        
        if let work = dictionary["workLocation"] as? String {
            homeLocation = work
        }
    
        if let index = dictionary["accountType"] as? Int {
            self.accountType = AccountType(rawValue: index)
        }
    }
}
