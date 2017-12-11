//
//  FavoritedThing.swift
//  whats-that
//
//  Created by Tarek Hatata on 12/11/17.
//  Copyright © 2017 Tarek Hatata. All rights reserved.
//

import Foundation
import UIKit

class FavoritedThing : NSObject {
    // only store title and description (image in documents directory)
    let thingTitle : String
    let thingDescription : String
    let imageFilename : String
    
    // keys
    let titleKey = "thingTitle"
    let descriptionKey = "thingDescription"
    let imageFilenameKey = "thingImageFilename"
    
    // init func
    init(title : String, description : String, imageFilename : String) {
        self.thingTitle = title
        self.thingDescription = description
        self.imageFilename = imageFilename
    }
    
    required init?(coder aDecoder : NSCoder) {
        thingTitle = aDecoder.decodeObject(forKey: titleKey) as! String
        thingDescription = aDecoder.decodeObject(forKey: descriptionKey) as! String
        imageFilename = aDecoder.decodeObject(forKey: imageFilenameKey) as! String
    }
}

extension FavoritedThing : NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(thingTitle, forKey: titleKey)
        aCoder.encode(thingDescription, forKey: descriptionKey)
        aCoder.encode(imageFilename, forKey: imageFilenameKey)
    }
}
