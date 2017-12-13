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
    
    func removeFavoritedThing(thing : FavoritedThing) {
        // create user defaults
        let userDefaults = UserDefaults.standard
        
        // get all favorited things and remove the specified thing
        var favoritedThings = fetchFavoritedThings()
        
        // variable for index to remove
        var idx = 0
        
        // loop through each favorited thing to find one to remove
        for favoritedThing in favoritedThings {
            // check if all attributes match
            if favoritedThing.thingTitle == thing.thingTitle &&
                favoritedThing.thingDescription == thing.thingDescription &&
                favoritedThing.imageFilename == thing.imageFilename {
                // if so, remove from array
                favoritedThings.remove(at: idx)
                break
            }
            // increment index
            idx += 1
        }
        
        // save in user defaults
        let data = NSKeyedArchiver.archivedData(withRootObject: favoritedThings)
        userDefaults.set(data, forKey: favoritedThingKey)
    }
    
    // separate function to detect if file already exists
    func fileExistsInDocumentsDirectory(filename : String) -> Bool {
        // get file manager
        let fileManager = FileManager.default
        
        // get image path
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(filename)
        
        // check if image is stored in documents directory, and return appropraite bool
        if fileManager.fileExists(atPath: imagePath) {
            return true
        } else {
            return false
        }
    }
    
    func loadImage(filename : String) -> UIImage? {
        // get file manager
        let fileManager = FileManager.default
        
        // get image path
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(filename)
        
        // check if image is stored in documents directory
        if fileManager.fileExists(atPath: imagePath) {
            // if so, return the UIImage
            return UIImage(contentsOfFile: imagePath)
        } else {
            // otherwise, return nil
            return nil
        }
    }
    
    func saveImage(image : UIImage, filename : String) {
        // get file manager
        let fileManager = FileManager.default
        
        // get paths
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(filename)
        
        // get image data using JPEG representation
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        
        // create file at path
        fileManager.createFile(atPath: paths, contents: imageData, attributes: nil)
    }
}
