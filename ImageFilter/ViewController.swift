//
//  ViewController.swift
//  ImageFilter
//
//  Created by Michael Tirenin on 8/4/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, PhotoSelectedDelegate, PHPhotoLibraryChangeObserver {
    
    var bandwWasClicked : Bool = false
    var sepiaWasClicked : Bool = false
    
    let photoPicker = UIImagePickerController()
    let cameraPicker = UIImagePickerController()
    let cancelPicker = UIImagePickerController()
    var imageViewSize : CGSize!
    var actionController = UIAlertController(title: "Title", message: "Message", preferredStyle: UIAlertControllerStyle.Alert)

    // filter
    var selectedAsset : PHAsset?
    let adjustmentFormatterIdentifier = "com.ImageFilter.michaeltirenin"
    var context = CIContext(options: nil)
    
    @IBOutlet weak var photoButtonOutlet: UIButton!
    
    @IBOutlet weak var getPhotoFromImageOutlet: UIButton!
    
    @IBOutlet weak var mainImageView: UIImageView!

//    let alertView = UIAlertController(title: "NOTE", message: "Get ready: you're about to be asked for permission to use your Camera or Photo Library.", preferredStyle: UIAlertControllerStyle.Alert)
    
//    let actionController = UIAlertController(title: "Add Photo", message: "Choose your photo source.", preferredStyle: UIAlertControllerStyle.ActionSheet)
    
//    var initialLoad = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupActionController() // necessary? or just in viewWillAppear
        
        self.photoPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.photoPicker.allowsEditing = true
        self.photoPicker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            self.cameraPicker.sourceType = UIImagePickerControllerSourceType.Camera
            self.cameraPicker.allowsEditing = true
            self.cameraPicker.delegate = self
        }
        
        mainImageView.layer.borderColor = UIColor.grayColor().CGColor
        mainImageView.layer.borderWidth = 1.5
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        if !self.initialLoad {
//            self.setupActionController()
//            self.initialLoad = true
//        }
        self.imageViewSize = self.mainImageView.frame.size
        
    }

// to fix lag from PhotoVC to ViewVC - see Alex's file
//    func loadImageForAsset(asset: PHAsset, completionHandler: (Void) -> Void) {
//        self.
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "ShowGrid" {
            let gridVC = segue.destinationViewController as GridViewController
            // fetch all assets
            gridVC.assetsFetchResult = PHAsset.fetchAssetsWithOptions(nil)
            gridVC.delegate = self
            
//            if (self.bandwFilterButtonOutlet) {
//                self.bandwFilterButtonOutlet.hidden = false
//            }
//            if (self.sepiaFilterButtonOutlet) {
//                self.sepiaFilterButtonOutlet.hidden = false
//            }
        }
    }

    func checkAuthentication(completionHandler: (PHAuthorizationStatus) -> Void) -> Void {
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .NotDetermined:
            println("not determined") // initial state (when app is first launched)
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                completionHandler(status)
            // add alertView for "first time" use
            })
        default:
//            println("restricted") // something else is restring them e.g. parental control
//            println("denied")
            completionHandler(PHPhotoLibrary.authorizationStatus())
        }
    }

    func setupActionController() {
        
        self.actionController = UIAlertController(title: "Photo Select", message: "Choose photo source", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        if self.actionController.popoverPresentationController {
            //self.actionController.modalPresentationStyle = UIModalPresentationStyle.Popover
            self.actionController.popoverPresentationController.sourceView = self.photoButtonOutlet
        }
        ////// check on this:
        self.actionController.modalPresentationStyle = UIModalPresentationStyle.PageSheet
        
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
        
                    let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
        
                        if NSUserDefaults.standardUserDefaults().objectForKey("notFirstRun") {
                            println("1st run")
                            //self.presentViewController(self.alertView, animated: true, completion: nil)
                            self.presentViewController(self.cameraPicker, animated: true, completion: nil)
                        } else {
                            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "notFirstRun")
                            println("NOT 1st run")
                            //self.presentViewController(self.alertView, animated: true, completion: nil)
                            self.presentViewController(self.cameraPicker, animated: true, completion: nil)
                        }
                    })
                    self.actionController.addAction(cameraAction)
                }

        let photoAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: {(action : UIAlertAction!) -> Void in

//            self.performSegueWithIdentifier("ShowGrid", sender: self) // without checking auth
            
            self.checkAuthentication({ (status) -> Void in
                if status == PHAuthorizationStatus.Authorized {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.performSegueWithIdentifier("ShowGrid", sender: self)
                    })
                }
            })
        })
        
        self.actionController.addAction(photoAction)
//    }
//        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
//            
//            let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
//                
//                if NSUserDefaults.standardUserDefaults().objectForKey("notFirstRun") {
//                    println("1st run")
//                    //self.presentViewController(self.alertView, animated: true, completion: nil)
//                    self.presentViewController(self.cameraPicker, animated: true, completion: nil)
//                } else {
//                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "notFirstRun")
//                    println("NOT 1st run")
//                    //self.presentViewController(self.alertView, animated: true, completion: nil)
//                    self.presentViewController(self.cameraPicker, animated: true, completion: nil)
//                }
//            })
//            self.actionController.addAction(cameraAction)
//        }
//
//        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
//            self.presentViewController(self.photoPicker, animated: true, completion: nil)
//        })
//        
//        self.actionController.addAction(photoLibraryAction)
//
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
        self.actionController.addAction(cancelAction)
    }

    @IBAction func getPhotoButton(sender: UIButton) {
        
//        self.presentViewController(self.photoPicker, animated: true, completion: nil)
        if self.actionController.popoverPresentationController {
            self.actionController.popoverPresentationController.sourceView = self.photoButtonOutlet
//            self.actionController.popoverPresentationController.sourceRect =
        }
        self.presentViewController(self.actionController, animated: true, completion: nil)
    }
    
    @IBAction func getPhotoFromImageButton(sender: UIButton) {
        
//        self.presentViewController(self.photoPicker, animated: true, completion: nil)
        if self.actionController.popoverPresentationController {
            self.actionController.popoverPresentationController.sourceView = self.getPhotoFromImageOutlet
            self.actionController.popoverPresentationController.sourceRect = CGRect(x: 125, y: 300, width: 0, height: 0)
        }
        self.presentViewController(self.actionController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        
        var editedImage = info[UIImagePickerControllerEditedImage] as UIImage!
        self.mainImageView.image = editedImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func photoSelected(asset: PHAsset) -> Void {
//filter
        self.selectedAsset = asset
        self.updateImage()
//
//        var targetSize = CGSize(width: CGRectGetWidth(self.mainImageView.frame), height: CGRectGetHeight(self.mainImageView.frame))
//        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
//            self.mainImageView.image = image
//        }
    }
    
    @IBOutlet weak var bandwFilterButtonOutlet: UIButton!
    
    @IBAction func bandwFilterButton(sender: UIButton) {
        bandwWasClicked = true
        filter()
    }
    
    @IBOutlet weak var sepiaFilterButtonOutlet: UIButton!
    
    @IBAction func sepiaFilterButton(sender: UIButton) {
        sepiaWasClicked = true
        filter()
    }
    
    func filter() {
        
        var options = PHContentEditingInputRequestOptions()
        options.canHandleAdjustmentData = {(data : PHAdjustmentData!) -> Bool in
            // used to share identifiers
            return data.formatIdentifier == self.adjustmentFormatterIdentifier && data.formatVersion == "1.0"
        }
        
        self.selectedAsset!.requestContentEditingInputWithOptions(
            options, completionHandler: { (contentEditingInput: PHContentEditingInput!, info:[NSObject : AnyObject]!) -> Void in
                
                // grab image, convert to CIImage
                var url = contentEditingInput.fullSizeImageURL
                var orientation = contentEditingInput.fullSizeImageOrientation
                var inputImage = CIImage(contentsOfURL: url).imageByApplyingOrientation(orientation)
                // also written as
//                var inputImage = CIImage(contentsOfURL: url)
//                inputImage = inputImage.imageByApplyingOrientation(orientation)
                
                // create filter, creat output image
                
                var filter : CIFilter!
                
                if self.bandwWasClicked == true {
//                    filter = CIFilter(name: "CIUnsharpMask")
                    filter = CIFilter(name: "CIPhotoEffectMono")
                    self.bandwWasClicked = false
                }
                
                if self.sepiaWasClicked == true {
                    filter = CIFilter(name: "CISepiaTone")
                    self.sepiaWasClicked = false
                }
                
                filter.setDefaults() // necessary?
                filter.setValue(inputImage, forKey: kCIInputImageKey)
                var outputImage = filter.outputImage
                
                // save
                var cgImage = self.context.createCGImage(outputImage, fromRect: outputImage.extent())
                var finalImage = UIImage(CGImage: cgImage)
                var jpegData = UIImageJPEGRepresentation(finalImage, 0.5) // need to write data to disk // changed from 1.0 to 0.5
                
                var adjustmentData = PHAdjustmentData(formatIdentifier: self.adjustmentFormatterIdentifier, formatVersion: "1.0'", data: jpegData)
                var contentEditingOutput = PHContentEditingOutput(contentEditingInput: contentEditingInput)
                jpegData.writeToURL(contentEditingOutput.renderedContentURL, atomically: true)
                contentEditingOutput.adjustmentData = adjustmentData
                
                // request change
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    
                    var request = PHAssetChangeRequest(forAsset: self.selectedAsset)
                    request.contentEditingOutput = contentEditingOutput
                    
                    }, completionHandler: {(success: Bool, error: NSError!) -> Void in
                        
                        if !success {
                            println(error.localizedDescription)
                        }
                })
        })
    }
    
    func updateImage() {
        
        var targetSize = self.mainImageView.frame.size
        PHImageManager.defaultManager().requestImageForAsset(self.selectedAsset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil) {(result: UIImage!, [NSObject : AnyObject]!) -> Void in
            
            self.mainImageView.image = result
        }
    }
    
    func photoLibraryDidChange(changeInstance: PHChange!) {
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            
            var changeDetails = changeInstance.changeDetailsForObject(self.selectedAsset)
            if changeDetails != nil {
               
                self.selectedAsset = changeDetails.objectAfterChanges as? PHAsset
                
                if changeDetails.assetContentChanged {
                   
                    self.updateImage()
                }
            }
        }
    }
    
}