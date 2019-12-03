//
//  Photos.swift
//  virtualTourist
//
//  Created by Hema on 11/26/19.
//  Copyright © 2019 Hema. All rights reserved.
//

import Foundation

struct Photos: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    let url_m: String
    let height_m: Int
    let width_m: Int
}

