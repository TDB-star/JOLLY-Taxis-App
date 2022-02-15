//
//  User.swift
//  JOLLY Taxis
//
//  Created by Tatiana Dmitrieva on 15.02.2022.
//

import Foundation

struct User {
    let fullname: String
    let email: String
    let accountType: Int
    
    init(_ dictionary: NSDictionary) {
        fullname = dictionary["fullname"] as? String ?? ""
        email = dictionary["email"] as? String ?? ""
        accountType = dictionary["accountType"] as? Int ?? 0
    }
}
