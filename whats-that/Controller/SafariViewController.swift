//
//  SafariViewController.swift
//  What's That
//
//  Created by Tarek Hatata on 11/27/17.
//  Copyright © 2017 Tarek Hatata. All rights reserved.
//

import UIKit
import SafariServices

class SafariViewController: UIViewController {
    
    // variable to hold the url template
    var wikiUrl = "https://en.wikipedia.org/?curid=16161443"
    
    // variable to hold the page id
    var pageId : Int = 16161443

    override func viewDidLoad() {
        super.viewDidLoad()

        // show safari view controller
        if let url = URL(string: wikiUrl.replacingOccurrences(of: "16161443", with: "\(pageId)")) {
            // configure safari controller
            let config = SFSafariViewController.Configuration()
            
            // enable reader if available
            config.entersReaderIfAvailable = true
            
            // create view controller
            let vc = SFSafariViewController(url: url, configuration: config)
            
            // present view controller
            present(vc, animated: true)
        }
        
        // when done, pop back to photo details by unwrapping navigation controller
        if let controller = self.navigationController {
            controller.popViewController(animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
