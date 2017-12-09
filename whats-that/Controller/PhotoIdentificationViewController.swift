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
    
    // variable to hold google vision results
    var googleVisionResults = [GoogleVisionResult]()
    
    // cell reuse id
    let cellReuseId = "photoIdCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // show loading screen
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        // register the table view cell class and its reuse id
        resultsTable.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseId)
        
        // set delegate and data source to self
        resultsTable.delegate = self
        resultsTable.dataSource = self
        
        // check if image was passed correctly before segue
        guard let image = image else {
            // error passing image to this view controller
            print("error passing image to view controller")
            return
        }
        
        // display image behind the loading screen
        imageChosen.image = image
        
        // initialize Google Vision API Manager
        let googleManager = GoogleVisionAPIManager()
        
        // designate self as the receiver of the fetchGoogleVisionResults callbacks
        googleManager.delegate = self
        
        // pass image to object to fetch results
        googleManager.fetchGoogleVisionResults(image: image)
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
        
        // set the text of the cell
        cell.textLabel?.text = googleVisionResults[indexPath.row].description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected \(googleVisionResults[indexPath.row].description)!")
    }
}

extension PhotoIdentificationViewController : GoogleVisionResultDelegate {
    func resultsFound(results: [GoogleVisionResult]) {
        // store results in local storage and update labels
        self.googleVisionResults = results
        
        // update labels on the main UI thread
        DispatchQueue.main.async {
            // hide the loading screen
            MBProgressHUD.hide(for: self.view, animated: true)
            
            // reload data for the table
            self.resultsTable.reloadData()
        }
    }
    
    func resultsNotFound() {
        print("results not found!")
    }
}
