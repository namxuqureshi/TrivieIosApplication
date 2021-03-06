//
//  ErrorClas.swift
//  BingLine
//
//  Created by Shahid Saleem on 2/17/21.
//

import Foundation

struct ErrorHandleDatum : Codable {
    
    let email : [String]?
    let phone : [String]?
    
    
    enum CodingKeys: String, CodingKey {
        case email = "email"
        case phone = "phone"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        email = try values.decodeIfPresent([String].self, forKey: .email)
        phone = try values.decodeIfPresent([String].self, forKey: .phone)
    }
    
}

