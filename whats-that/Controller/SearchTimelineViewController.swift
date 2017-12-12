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
            print("error")
            return
        }
        
        // create twitter serach timeline data source
        let dataSource = TWTRSearchTimelineDataSource(searchQuery: query, apiClient: TWTRAPIClient())
        
        // set result type to mixed (both popular and real time results)
        dataSource.resultType = "mixed"
        
        // set to self
        self.dataSource = dataSource
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
