//
//  GoogleVisionAPIManager.swift
//  What's That
//
//  Created by Tarek Hatata on 11/27/17.
//  Copyright © 2017 Tarek Hatata. All rights reserved.
//

import Foundation
import UIKit

protocol GoogleVisionResultDelegate {
    func resultsFound(results : [GoogleVisionResult])
    func resultsNotFound()
}

class GoogleVisionAPIManager {
    // variable for result delegate (if present)
    var delegate : GoogleVisionResultDelegate?
    
    // variables to store url w/key for Google Vision API
    private var key = "AIzaSyDn1LlLtVI73HaZDH4zICjRZmoSepZWOZ0"
    private var googleUrl = "https://vision.googleapis.com/v1/images:annotate"
    
    // variable to store image to search/display
    private var image : UIImage
    
    init () {
        image = UIImage()
    }
    
    func fetchGoogleVisionResults(image : UIImage) {
        // save photo for processing
        self.image = image
        
        // create URL request from components
        let url = googleUrl + "?key=\(key)"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // get based 64 encoded image string
        let encodedImage = base64EncodeImage(image)
        
        // create json object with encoded image inside
        let jsonObject = [
            "requests": [
                "image": [
                    "content": encodedImage
                ],
                "features": [
                    [
                        "type": "LABEL_DETECTION",
                        "maxResults": 5
                    ]
                ]
            ]
        ]
        
        // serialize the data for POST request
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject)
        
        guard let data = jsonData else {
            // error serializing
            print("error serializing!")
            return
        }
        
        // attach data to the request
        request.httpBody = data

        // Run the request on a background thread
        DispatchQueue.global().async { self.runRequest(request) }
    }
    
    private func base64EncodeImage(_ image: UIImage) -> String {
        
        // create image data from PNG representation
        let imagedata = UIImagePNGRepresentation(image)
        
        // return encoded string
        print(imagedata!.base64EncodedString(options: .endLineWithCarriageReturn))
        
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    func runRequest(_ request: URLRequest) {
        print("running request!")
        // run the request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // check for valid response with 200 (success)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("no valid response")
                self.delegate?.resultsNotFound()
                
                return
            }
            
            // ensure data is not null
            guard let data = data else {
                print("data is null")
                self.delegate?.resultsNotFound()
                
                return
            }

            // create json decoder to attempt to decode
            let decoder = JSONDecoder()
            let decodedRoot = try? decoder.decode(Root.self, from: data)
            
            // ensure json structure matches what we expected
            guard let root = decodedRoot else {
                print("json structure doesn't match expectation")
                self.delegate?.resultsNotFound()
                
                return
            }
            
            // create array of GoogleVisionResult objects
            var googleResults = [GoogleVisionResult]()
            
            // get the results array that stored the description of results
            let results = root.responses[0].labelAnnotations
            
            // get the strings from our decoded object
            for result in results {
                let googleResult = GoogleVisionResult(description: result.description)
                googleResults.append(googleResult)
            }
            
            // send result through the delegate
            self.delegate?.resultsFound(results: googleResults)
        }
        
        task.resume()
    }
}
