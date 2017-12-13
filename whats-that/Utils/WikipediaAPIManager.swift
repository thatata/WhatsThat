//
//  WikipediaAPIManager.swift
//  What's That
//
//  Created by Tarek Hatata on 11/27/17.
//  Copyright © 2017 Tarek Hatata. All rights reserved.
//

import Foundation

protocol WikipediaResultsDelegate {
    func wikiResultFound(result : WikipediaResult)
    func wikiResultNotFound()
}

class WikipediaAPIManager {
    // variable for delegate
    var delegate : WikipediaResultsDelegate?
    
    // store the Wikipedia URL
    private var wikiUrl = "https://en.wikipedia.org/w/api.php"
    
    func fetchWikipediaResults(searchTerm : String) {
        var urlComponents = URLComponents(string: wikiUrl)!
        
        urlComponents.queryItems = [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "prop", value: "extracts"),
            URLQueryItem(name: "exintro", value: ""),
            URLQueryItem(name: "explaintext", value: ""),
            URLQueryItem(name: "titles", value: searchTerm),
        ]
        
        let url = urlComponents.url!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // run the request on a background thread
        DispatchQueue.global().async { self.runRequest(request: request) }
    }
    
    private func runRequest(request : URLRequest) {
        // create URL session to run request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            //check for valid response with 200 (success)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                self.delegate?.wikiResultNotFound()
                
                return
            }
            
            // make sure JSON serialization works
            guard let data = data, let wikiJsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] ?? [String:Any]() else {
                self.delegate?.wikiResultNotFound()
                
                return
            }
            
            // convert to JSON (first key of this dict has the next object)
            guard let queryJsonObject = wikiJsonObject["query"] as? [String:Any],
                let pagesJsonObject = queryJsonObject["pages"] as? [String:Any],
                let pageJsonObject = pagesJsonObject[pagesJsonObject.keys.first!] as? [String:Any] else {
                    self.delegate?.wikiResultNotFound()
                    
                    return
            }
            // create WikipediaResult variable from this json object (replace values with default values if value DNE)
            let wikiResult = WikipediaResult(title: pageJsonObject["title"] as? String ?? "", pageId: pageJsonObject["pageid"] as? Int ?? -1, description: pageJsonObject["extract"] as? String ?? "")
            
            // return the wiki result to the delegate
            self.delegate?.wikiResultFound(result: wikiResult)
        }
        task.resume()
    }
}
