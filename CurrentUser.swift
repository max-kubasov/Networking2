//
//  CurrentUser.swift
//  Networking
//
//  Created by Max on 24.01.2023.
//  Copyright © 2023 Max. All rights reserved.
//

import Foundation

struct CurrentUser {
    
    let uid: String
    let name: String
    let email: String
    
    init?(uid: String, data: [String: Any]) {
        
        guard
            let name = data["name"] as? String,
            let email = data["email"] as? String
        else { return nil }
             
        self.uid = uid
        self.name = name
        self.email = email
    }
}
