//
//  AlamofireNetworkRequest.swift
//  Networking
//
//  Created by Max on 15.01.2023.
//  Copyright © 2023 Alexey Efimov. All rights reserved.
//

import Foundation
import Alamofire


class AlamofireNetworkRequest {
    
    static func sendRequest(url: String) {
        
        guard let url = URL(string: url) else { return }
        
        AF.request(url).response { response in
            print(response)
        }
        
        AF.request(url).responseJSON { response in
            print(response)
        }
        
        
        
    }
}
