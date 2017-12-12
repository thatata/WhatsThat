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
    // store title, description, filename, and wiki page id
    let thingTitle : String
    let thingDescription : String
    let imageFilename : String
    let wikiPageId : Int
    
    // keys
    let titleKey = "thingTitle"
    let descriptionKey = "thingDescription"
    let imageFilenameKey = "thingImageFilename"
    let wikiPageIdKey = "thingWikiPageId"
    
    // init func
    init(title : String, description : String, imageFilename : String, wikiPageId : Int) {
        self.thingTitle = title
        self.thingDescription = description
        self.imageFilename = imageFilename
        self.wikiPageId = wikiPageId
    }
    
    required init?(coder aDecoder : NSCoder) {
        thingTitle = aDecoder.decodeObject(forKey: titleKey) as! String
        thingDescription = aDecoder.decodeObject(forKey: descriptionKey) as! String
        imageFilename = aDecoder.decodeObject(forKey: imageFilenameKey) as! String
        wikiPageId = aDecoder.decodeInteger(forKey: wikiPageIdKey)
    }
}

extension FavoritedThing : NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(thingTitle, forKey: titleKey)
        aCoder.encode(thingDescription, forKey: descriptionKey)
        aCoder.encode(imageFilename, forKey: imageFilenameKey)
        aCoder.encode(wikiPageId, forKey: wikiPageIdKey)
    }
}
