//
//  SearchTimelineViewController.swift
//  What's That
//
//  Created by Tarek Hatata on 11/27/17.
//  Copyright © 2017 Tarek Hatata. All rights reserved.
//

import UIKit
import TwitterKit

class SearchTimelineViewController: TWTRTimelineViewController {
    
    // variable to store search query
    var searchQuery : String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // force unwrap search query
        guard let query = searchQuery else {
            // show error message
            showError(errorTitle: "Error Passing Search Query", errorMessage: "Could not properly pass title in as the search query. Please try again.")
            return
        }
        
        // create twitter serach timeline data source
        let dataSource = TWTRSearchTimelineDataSource(searchQuery: query, apiClient: TWTRAPIClient())
        
        // set result type to mixed (both popular and real time results)
        dataSource.resultType = "mixed"
        
        // set to self
        self.dataSource = dataSource
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
