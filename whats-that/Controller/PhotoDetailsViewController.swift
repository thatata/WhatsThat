//
//  PhotoDetailsViewController.swift
//  What's That
//
//  Created by Tarek Hatata on 11/27/17.
//  Copyright © 2017 Tarek Hatata. All rights reserved.
//

import UIKit
import SafariServices

class PhotoDetailsViewController: UIViewController {
    
    // store the image chosen
    var image : UIImage?
    
    // store the wiki results of the selected ID
    var wikiResult : WikipediaResult?
    
    // variable to keep track of if this photo has been favorited (default is false)
    var isFavorited = false
    
    // variable to store FavoritedThing object (if it exists)
    var favoritedThing : FavoritedThing?
    
    // variable to hold the wiki url template
    var wikiUrl = "https://en.wikipedia.org/?curid=16161443"
    
    // outlets for the image view and label
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var wikiText: UITextView!
    @IBOutlet weak var favoriteIcon: UIButton!
    @IBOutlet weak var photoTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // display the wiki summary and image
        imageView.image = image
        
        // show the top of the text first, and don't let user edit
        wikiText.setContentOffset(.zero, animated: false)
        wikiText.allowsEditingTextAttributes = false
        
        // check isFavorited if we're selecting a favorite or not
        if isFavorited {
            // if so, initialize WikipediaResult object for processing
            
            // unwrap favorited thing
            guard let thing = favoritedThing else {
                // show error message
                showError(errorTitle: "Error Unwrapping Favorited Thing", errorMessage: "Could not unwrap FavoritedThing object. Please try again.")
                return
            }
            
            // init wiki result with favorited thing attributes
            wikiResult = WikipediaResult(title: thing.thingTitle, pageId: thing.wikiPageId, description: thing.thingDescription)
            
            // set appropriate favorite icon
            favoriteIcon.setImage(UIImage(named: "favorited"), for: .normal)
        } else {
            // otherwise, WikipediaResult var is already set
            // set appropriate favorite icon
            favoriteIcon.setImage(UIImage(named: "notFavorited"), for: .normal)
        }
        
        // unwrap Wikipedia result
        guard let result = wikiResult else {
            // show error message
            showError(errorTitle: "Error Unwrapping Wiki Result", errorMessage: "Could not unwrap WikipediaResult object. Please try again.")
            return
        }
        
        // set text (if description is blank, or simply "refers to" another description, change it)
        wikiText.text = (result.description.isEmpty || result.description.contains("may refer to")) ? "No description available. Check the Wikipedia link for more information!" : result.description
        
        // set the title (capitalized)
        photoTitle.text = result.title.capitalized
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTweets" {
            // pass title as search query to the vc
            let destinationVC = segue.destination as? SearchTimelineViewController
            
            // unwrap title and destination vc
            guard let result = wikiResult,
                  let vc = destinationVC else {
                    // show error message
                    showError(errorTitle: "Error Unwrapping Wiki Result and Destination VC", errorMessage: "Could not unwrap WikipediaResult object or destination view controller. Please try again.")
                    return
            }
            
            // set title
            vc.searchQuery = result.title
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func wikiButtonPressed(_ sender: Any) {
        // unwrap the wiki result
        guard let result = wikiResult else {
            // show error message
            showError(errorTitle: "Error Unwrapping Wiki Result", errorMessage: "Could not unwrap WikipediaResult object. Please try again.")
            return
        }
        
        // create the URL based on the result page ID
        if let url = URL(string: wikiUrl.replacingOccurrences(of: "16161443", with: "\(result.pageId)")) {
            // create configuration object for SafariViewController
            let config = SFSafariViewController.Configuration()
            
            // enable reader if available
            config.entersReaderIfAvailable = true
            
            // create instance of SafariViewController
            let vc = SafariViewController(url: url, configuration: config)
            
            // present view controller
            present(vc, animated: true, completion: nil)
        } else {
            // show error message
            showError(errorTitle: "Error Creating URL Object", errorMessage: "Could not successfully create URL object. Please try again.")
        }
    }
    
    @IBAction func tweetsButtonPressed(_ sender: Any) {
        // perform segue to SearchTimelineViewController
        performSegue(withIdentifier: "showTweets", sender: self)
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        // unwrap wiki result to get title to share
        guard let result = wikiResult else {
            // show error message
            showError(errorTitle: "Error Unwrapping Wiki Result", errorMessage: "Could not unwrap WikipediaResult object. Please try again.")
            return
        }
        
        // set up activity view controller
        let textToShare = ["I just found out what a \(result.title) is! Here's a description: \(result.description)"]
        
        // set up activity view controller
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        
        // set popover presentation controller to avoid iPad crashes
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        // present view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func favoriteButtonPressed(_ sender: Any) {
        // check if thing is already favorited
        if isFavorited {
            // if so, remove favorite
            removeFavorite()
        } else {
            // otherwise, add favorite
            addFavorite()
        }
        
        // set favorite button icon
        favoriteIcon.setImage(isFavorited ? UIImage(named: "favorited") : UIImage(named: "notFavorited"), for: .normal)
    }
    
    func addFavorite() {
        // force unwrap wiki result and image to save
        guard let result = wikiResult, let image = image else {
            // show error message
            showError(errorTitle: "Error Unwrapping Wiki Result and Image", errorMessage: "Could not unwrap WikipediaResult object or UIImage object. Please try again.")
            return
        }
        
        // check if default filename is taken already (ignore file extension until filename is valid)
        var filename = result.title.trimmingCharacters(in: .whitespaces)
        
        // check if file already exists, if so change filename
        while PersistanceManager.sharedInstance.fileExistsInDocumentsDirectory(filename: filename.appending(".jpg")) {
            // if so, add enough zeroes to filename until file exists
            filename = filename.appending("0")
        }
        
        // add file extension before proceeding
        filename = filename.appending(".jpg")
        
        // create favorited thing from WikipediaResult
        let favoritedThing = FavoritedThing(title: result.title, description: result.description, imageFilename: filename, wikiPageId: result.pageId)
        
        // save favorited thing in local storage
        self.favoritedThing = favoritedThing
        
        // save using persistance manager
        PersistanceManager.sharedInstance.saveFavoritedThing(thing: favoritedThing, image: image)
        
        // set isFavorited var to true
        isFavorited = true
    }
    
    func removeFavorite() {
        // force unwrap favorited thing
        guard let thing = favoritedThing else {
            // show error message
            showError(errorTitle: "Error Unwrapping Favorited Thing", errorMessage: "Could not unwrap FavoritedThing object. Please try again.")
            return
        }
        
        // call function to remove thing from user defaults
        PersistanceManager.sharedInstance.removeFavoritedThing(thing: thing)
        
        // set isFavorited var to false to update icon
        isFavorited = false
    }
    
    private func showError(errorTitle : String, errorMessage : String) {
        // show an error message in an asynchronous task
        DispatchQueue.main.async {
            // create alert
            let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
            
            // add ok action
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            
            // present alert
            self.present(alert, animated: true, completion: nil)
        }
    }
}
