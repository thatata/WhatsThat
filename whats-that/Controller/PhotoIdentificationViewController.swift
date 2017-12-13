//
//  PhotoIdentificationViewController.swift
//  What's That
//
//  Created by Tarek Hatata on 11/27/17.
//  Copyright © 2017 Tarek Hatata. All rights reserved.
//

import UIKit
import AVFoundation
import MBProgressHUD

class PhotoIdentificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // image to show in image view
    var image : UIImage?
    
    // image view to hold image selected/taken
    @IBOutlet weak var imageChosen: UIImageView!
    
    // table view
    @IBOutlet weak var resultsTable: UITableView!
    
    // variable to hold google vision results (initialize so the table view can generate)
    var googleVisionResults = [GoogleVisionResult]()
    
    // cell reuse id
    let cellReuseId = "photoIdCell"
    
    // variable to hold wikipedia results
    var wikiResult : WikipediaResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register the table view cell class and its reuse id
        resultsTable.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseId)
        
        // set delegate and data source to self
        resultsTable.delegate = self
        resultsTable.dataSource = self
        
        // check if image was passed correctly before segue
        guard let image = image else {
            // error passing image to this view controller
            // show error message
            showError(errorTitle: "Error Passing Image to Photo ID", errorMessage: "Could not properly pass iamge  to this view controller. Please try again.")
            return
        }
        
        // display image behind the loading screen
        imageChosen.image = image
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return googleVisionResults.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create cell if needed, or reuse an old one
        let cell = self.resultsTable.dequeueReusableCell(withIdentifier: cellReuseId, for: indexPath)
        
        // set the text of the cell (capitalized for presentation)
        cell.textLabel?.text = googleVisionResults[indexPath.row].description.capitalized
        
        // set the alignment to center
        cell.textLabel?.textAlignment = .center
        
        return cell
    }
    
    // function to handle when the user selects a row in the table
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // finish select animation
        resultsTable.deselectRow(at: indexPath, animated: true)
        
        // show loading screen
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        // create new WikipediaAPIManager to get detailed description
        let wikiAPIManager = WikipediaAPIManager()
        
        // set delegate to self
        wikiAPIManager.delegate = self
        
        // call function to fetch wiki results with selected row
        wikiAPIManager.fetchWikipediaResults(searchTerm: googleVisionResults[indexPath.row].description)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "identifiedPhoto" {
            // store image and wiki results in the destination VC
            let destinationVC = segue.destination as? PhotoDetailsViewController
            
            // add image to the view controller
            destinationVC?.image = self.image

            // add wiki result to the view controller
            destinationVC?.wikiResult = self.wikiResult
        }
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

extension PhotoIdentificationViewController : WikipediaResultsDelegate {
    func wikiResultFound(result: WikipediaResult) {
        // save the wikipedia result in memory
        self.wikiResult = result
        
        // hide loading screen and perform segue in main UI thread
        DispatchQueue.main.async {
            // hide the loading screen
            MBProgressHUD.hide(for: self.view, animated: true)
            
            // perform segue to photo details scene
            self.performSegue(withIdentifier: "identifiedPhoto", sender: self)
        }
    }
    
    func wikiResultNotFound() {
        // show error message
        showError(errorTitle: "Error Fetching Wiki Results", errorMessage: "Could not fetch Wiki results! Please try again.")
    }
}
