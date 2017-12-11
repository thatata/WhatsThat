//
//  PhotoDetailsViewController.swift
//  What's That
//
//  Created by Tarek Hatata on 11/27/17.
//  Copyright © 2017 Tarek Hatata. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {
    
    // store the image chosen
    var image : UIImage?
    
    // store the wiki results of the selected ID
    var wikiResult : WikipediaResult?
    
    // outlets for the image view and label
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var wikiText: UITextView!
    @IBOutlet weak var favoriteIcon: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // display the wiki summary and image
        imageView.image = image
        
        // show the top of the text first, and don't let user edit
        wikiText.setContentOffset(.zero, animated: false)
        wikiText.allowsEditingTextAttributes = false
        
        // set the text
        wikiText.text = wikiResult?.description
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func wikiButtonPressed(_ sender: Any) {
        print("wiki button pressed")
    }
    
    @IBAction func tweetsButtonPressed(_ sender: Any) {
        print("tweets button pressed")
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        print("share button pressed")
    }
    
    @IBAction func favoriteButtonPressed(_ sender: Any) {
        // force unrwap wiki result and image to save
        guard let result = wikiResult, let image = image else {
            // wiki result has no data
            print("error")
            return
        }
        
        // create favorited thing from WikipediaResult and build filename
        let favoritedThing = FavoritedThing(title: result.title, description: result.description, imageFilename: result.title.trimmingCharacters(in: .whitespaces).appending(".jpg"))
        
        // save using persistance manager
        PersistanceManager.sharedInstance.saveFavoritedThing(thing: favoritedThing, image: image)
        
        // set favorite button icon
        favoriteIcon.setImage(UIImage(named: "favorited"), for: .normal)
    }
    
}
