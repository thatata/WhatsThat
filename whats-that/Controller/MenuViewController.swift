//
//  ViewController.swift
//  What's That
//
//  Created by Tarek Hatata on 11/26/17.
//  Copyright © 2017 Tarek Hatata. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import MBProgressHUD

class MenuViewController: UIViewController {
    
    // image picker to take/select a photo
    private let imagePicker = UIImagePickerController()
    
    // save source type for image picker (deafult is saved photos album)
    private var sourceType : UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.photoLibrary
    
    // variable to check if camera permission was granted
    private var cameraPermissionGranted : Bool = false
    
    // variable to check if photo library permission was granted
    private var photoLibraryPermissionGranted : Bool = false
    
    // variable to store image selected/taken
    private var image : UIImage = UIImage()
    
    // variable to store google vision results
    var googleVisionResults : [GoogleVisionResult]?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cameraChosen(_ sender: Any) {
        // prompt user to take a photo or select a photo
        imagePicker.delegate = self
        
        // allow user to edit
        imagePicker.allowsEditing = true
        
        // present alert
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // add action for camera selection
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            action in
                // Camera selected
                // set source type to camera
                self.sourceType = .camera
            
                // check if permission was already granted
                if !self.cameraPermissionGranted {
                    // if not, check permissions
                    self.checkCameraPermission()
                } else {
                    // otherwise, just prompt image picker
                    self.promptUIImagePicker()
                }
        }))
        
        // add action for photo library
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            action in
                // Photo Library selected
                // set source type to photo library
                self.sourceType = .photoLibrary
            
                // check if permission was already granted
                if !self.photoLibraryPermissionGranted {
                    // if not, check permissions
                    self.checkPhotoLibraryPermission()
                } else {
                    // otherwise, just prompt image picker
                    self.promptUIImagePicker()
                }
        }))
        
        // add cancel option
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // present alert
        present(alert, animated: true, completion: nil)
    }
    
    private func promptUIImagePicker() {
        // set source type of the image picker to the most recent
        imagePicker.sourceType = sourceType
        
        // check if source type is available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            // present the picker to the user
            present(imagePicker, animated: true, completion: nil)
        } else {
            // otherwise, show error message
            showError(errorTitle: "Source Type Error", errorMessage: "Source type \(sourceType) was not available!")
        }
    }
    
    private func checkPhotoLibraryPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
        case .authorized:
            // access is granted by user, so prompt picker
            promptUIImagePicker()
        case .notDetermined:
            // access is not determined, so request permission
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized {
                    // access authorized, so set permission granted and prompt picker (asynchronously)
                    DispatchQueue.main.async {
                        self.photoLibraryPermissionGranted = true
                        self.promptUIImagePicker()
                    }
                } else {
                    // access denied, so show error message
                    print("error??")
                    self.showError(errorTitle: "Photo Library Access", errorMessage: "Access denied.")
                }
            })
        case .restricted:
            // access is restricted, so error
            showError(errorTitle: "Photo Library Access", errorMessage: "Access is restricted.")
        case .denied:
            // access is denied by user, so error
            showError(errorTitle: "Photo Library Access", errorMessage: "Access denied.")
        }
    }
    
    private func checkCameraPermission() {
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        
        switch cameraAuthorizationStatus {
        case .authorized:
            // access is granted by the user, so prompt picker
            promptUIImagePicker()
        case .notDetermined:
            // access is not determined, so request permission
            AVCaptureDevice.requestAccess(for: cameraMediaType) { response in
                // check if response is true (not nil)
                if response {
                    DispatchQueue.main.async {
                        self.cameraPermissionGranted = true
                        self.promptUIImagePicker()
                    }
                } else {
                    // access denied, so show error message
                    self.showError(errorTitle: "Camera Access", errorMessage: "Access denied.")
                }
            }
        case .restricted:
            // user does not have access to camera, so error
            showError(errorTitle: "Camera Access", errorMessage: "Access is restricted.")
        case .denied:
            // access is denied, so error
            showError(errorTitle: "Camera Access", errorMessage: "Access denied.")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "choseCamera" {
            // pass image and results to PhotoIdentificationViewController
            let destinationVC = segue.destination as? PhotoIdentificationViewController
            
            // force unrwap results
            guard let results = googleVisionResults else {
                // error
                print("error storing google vision results")
                return
            }
            
            // add results to the view controller
            destinationVC?.googleVisionResults = results
            
            // add image to the view controller
            destinationVC?.image = self.image
        } else if segue.identifier == "favoritesChosen" {
            // get the favorited things from persistance manager
            let things = PersistanceManager.sharedInstance.fetchFavoritedThings()
            
            // pass to the favorites table vc
            let destinationVC = segue.destination as? FavoritePhotosTableViewController
            
            // add favorited things to controller
            destinationVC?.favorites = things
        }
    }
}

// MARK: Delegate Extension of View Controller, to handle image picking/taking
extension MenuViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // dismiss picker when cancelled
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // grab the UI image from info passed into this function
        var error = false
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            // assign to image
            self.image = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // assign to image
            self.image = originalImage
        } else {
            // show error
            showError(errorTitle: "Image Picking Error", errorMessage: "Error! Please Try Again!")
            error = true
        }
        
        // dismiss picker
        picker.dismiss(animated: true)
        
        // if no error occurred, fetch google vision results
        if !error {
            // show loading screen
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            // initialize Google Vision API Manager
            let googleManager = GoogleVisionAPIManager()
            
            // designate self as the receiver of the fetchGoogleVisionResults callbacks
            googleManager.delegate = self
            
            // pass image to object to fetch results
            googleManager.fetchGoogleVisionResults(image: image)
        }
    }
}

extension MenuViewController : GoogleVisionResultDelegate {
    func googleResultsFound(results: [GoogleVisionResult]) {
        // store results in local storage and update labels
        self.googleVisionResults = results
        
        // pass results to photo id on the main UI thread
        DispatchQueue.main.async {
            // hide the loading screen
            MBProgressHUD.hide(for: self.view, animated: true)
            
            // segue to photo id scene
            self.performSegue(withIdentifier: "choseCamera", sender: self)
        }
    }
    
    func googleResultsNotFound() {
        // error
        print("results not found!")
    }
}

