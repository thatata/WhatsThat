//
//  PersistanceManager.swift
//  What's That
//
//  Created by Tarek Hatata on 11/27/17.
//  Copyright © 2017 Tarek Hatata. All rights reserved.
//

import Foundation
import UIKit

class PersistanceManager {
    static let sharedInstance = PersistanceManager()
    
    // variable to store the key to favorited things
    let favoritedThingKey = "favoritedThings"
    
    func fetchFavoritedThings() -> [FavoritedThing] {
        // create user defaults
        let userDefaults = UserDefaults.standard
        
        // get data
        let data = userDefaults.object(forKey: favoritedThingKey) as? Data
        
        // check if data is not nil
        if let data = data {
            // data is not nil, so use it
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? [FavoritedThing] ?? [FavoritedThing]()
        } else {
            // data is nil, so return empty array
            return [FavoritedThing]()
        }
    }
    
    func saveFavoritedThing(thing : FavoritedThing, image : UIImage) {
        // save image in documents directory using filename attached to thing
        saveImage(image: image, filename: thing.imageFilename)
        
        // create user defaults
        let userDefaults = UserDefaults.standard
        
        // get all favorited things and append new thing
        var favoritedThings = fetchFavoritedThings()
        favoritedThings.append(thing)
        
        // save in user defaults
        let data = NSKeyedArchiver.archivedData(withRootObject: favoritedThings)
        userDefaults.set(data, forKey: favoritedThingKey)
    }
    
    func saveImage(image : UIImage, filename : String) {
        
    }
}
