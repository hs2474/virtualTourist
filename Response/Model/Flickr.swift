//
//  Flickr.swift
//  virtualTourist
//
//  Created by Hema on 11/26/19.
//  Copyright © 2019 Hema. All rights reserved.
//
//
//  flickr.swift
//  ontheMap
//
//  Created by Hema on 11/25/19.
//  Copyright © 2019 Hema. All rights reserved.
//

import Foundation
struct Flickr: Codable {
    
    let flickr: PhotoData
    
    enum CodingKeys: String, CodingKey {
        case flickr = "photos"
    }
    
}




