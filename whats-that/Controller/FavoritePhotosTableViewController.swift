//
//  FavoritePhotosTableTableViewController.swift
//  What's That
//
//  Created by Tarek Hatata on 11/27/17.
//  Copyright © 2017 Tarek Hatata. All rights reserved.
//

import UIKit

class FavoritePhotosTableViewController: UITableViewController {
    
    // variable to hold favorited things
    var favorites = [FavoritedThing]()
    
    // variable to hold selected favorite for segue
    var favoriteThing : FavoritedThing?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // fetch favorite things again
        favorites = PersistanceManager.sharedInstance.fetchFavoritedThings()
        
        // reload the data when the view loads
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            // force unwrap favorite to pass to photo details
            guard let favorite = favoriteThing else {
                print("error")
                return
            }
            
            // load the image from the documents directory
            let image = PersistanceManager.sharedInstance.loadImage(filename: favorite.imageFilename)
            
            // pass to the photo details vc
            let destinationVC = segue.destination as? PhotoDetailsViewController
            
            // add favorited things to controller
            destinationVC?.favoritedThing = favorite
            
            // add image to controller
            destinationVC?.image = image
            
            // set isFavorited to true
            destinationVC?.isFavorited = true
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get cell using favoriteCell reuse id
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath) as! FavoriteTableViewCell

        // set text (capitalized)
        cell.cellText.text = favorites[indexPath.row].thingTitle.capitalized
        
        // load image of favorite from persistance manager
        let image = PersistanceManager.sharedInstance.loadImage(filename: favorites[indexPath.row].imageFilename)
        
        // set image
        cell.cellImage.image = image
        
        // set the alignment to center
        cell.textLabel?.textAlignment = .center

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get favorited thing from list of favorites
        let selectedFavorite = favorites[indexPath.row]
        
        // store to pass through to photo details vc
        favoriteThing = selectedFavorite
        
        // perform segue to photo details
        performSegue(withIdentifier: "showDetails", sender: self)
    }
    
}
