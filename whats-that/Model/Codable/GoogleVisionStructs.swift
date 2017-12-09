//
//  GoogleVisionStructs.swift
//  What's That
//
//  Created by Tarek Hatata on 12/1/17.
//  Copyright © 2017 Tarek Hatata. All rights reserved.
//

import Foundation

struct Root: Codable {
    let responses: [Responses]
}

struct Responses: Codable {
    let labelAnnotations: [LabelAnnotations]
}

struct LabelAnnotations: Codable {
    let description: String
}
