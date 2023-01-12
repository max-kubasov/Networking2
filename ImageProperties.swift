//
//  ImageProperties.swift
//  Networking
//
//  Created by Max on 10.01.2023.
//  Copyright © 2023 Alexey Efimov. All rights reserved.
//

import UIKit

struct ImageProperties {
    
    let key: String
    let data: Data
    
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        guard let data = image.pngData() else { return nil }
        self.data = data
    }
}
