//
//  PhotoData.swift
//  virtualTourist
//
//  Created by Hema on 11/26/19.
//  Copyright © 2019 Hema. All rights reserved.
//

import Foundation
struct PhotoData: Codable {
    let currentPageNumber: Int
    let totalNumberOfPages: Int
    let photosPerPage: Int
    let total: String
    let photos: [Photos]
    
    enum CodingKeys: String, CodingKey {
        case currentPageNumber = "page"
        case totalNumberOfPages = "pages"
        case photosPerPage = "perpage"
        case total = "total"
        case photos = "photo"
    }
}

