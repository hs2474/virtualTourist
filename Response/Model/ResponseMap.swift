//
//  ResponseMap.swift
//  virtualTourist
//
//  Created by Hema on 11/26/19.
//  Copyright © 2019 Hema. All rights reserved.
//

import Foundation

struct ResponseMap: Codable {
    let statusCode: Int
    let statusMessage: String
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case statusMessage = "status_message"
    }
}

extension ResponseMap: LocalizedError {
    var errorDescription: String? {
        return statusMessage
    }
}

