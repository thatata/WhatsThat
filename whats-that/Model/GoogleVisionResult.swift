//
//  GoogleVisionResult.swift
//  What's That
//
//  Created by Tarek Hatata on 11/27/17.
//  Copyright © 2017 Tarek Hatata. All rights reserved.
//

import Foundation

struct GoogleVisionResult: Decodable {
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case description //this matches above
    }
}
