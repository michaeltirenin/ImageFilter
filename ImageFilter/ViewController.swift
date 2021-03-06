//
//  ViewController.swift
//  ImageFilter
//
//  Created by Michael Tirenin on 8/4/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, PhotoSelectedDelegate, PhotoTakenDelegate, PHPhotoLibraryChangeObserver {
    
//    var bandwWasClicked : Bool = false
//    var sepiaWasClicked : Bool = false
    
    var asset : PHAsset!
    
    var addPhotoImageWasClicked : Bool = false
    
    let photoPicker = UIImagePickerController()
    let cameraPicker = UIImagePickerController()
    let cancelPicker = UIImagePickerController()
    let camera2Picker = UIImagePickerController()
    
    var imageViewSize : CGSize!
    var actionController = UIAlertController(title: "Title", message: "Message", preferredStyle: UIAlertControllerStyle.Alert)

    // filter
    var selectedAsset : PHAsset?
    let adjustmentFormatterIdentifier = "com.ImageFilter.michaeltirenin"
    var context = CIContext(options: nil)
    
    @IBOutlet weak var addPhotoBarButtonOutlet: UIBarButtonItem!
    
    @IBOutlet weak var getPhotoFromImageOutlet: UIButton!
    
    @IBOutlet weak var mainImageView: UIImageView!

    let alertView = UIAlertController(title: "NOTE", message: "You'll be asked for your permission to use your Camera or Photo Library.", preferredStyle: UIAlertControllerStyle.Alert)
    
//    let actionController = UIAlertController(title: "Add Photo", message: "Choose your photo source.", preferredStyle: UIAlertControllerStyle.ActionSheet)
    
//    var initialLoad = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "The Photo Filter-er"
        
        self.setupActionController() // necessary? or just in viewWillAppear
        
        self.photoPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.photoPicker.allowsEditing = true
        self.photoPicker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            self.cameraPicker.sourceType = UIImagePickerControllerSourceType.Camera
            self.cameraPicker.allowsEditing = true
            self.cameraPicker.delegate = self
        }
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            self.camera2Picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.camera2Picker.allowsEditing = true
            self.camera2Picker.delegate = self
        }
        
//        mainImageView.layer.borderColor = UIColor.grayColor().CGColor
//        mainImageView.layer.borderWidth = 1.5
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if defaults.boolForKey("notFirstRun") {
            println("not first-time launch")
        } else {
            defaults.setBool(true, forKey: "notFirstRun")
            println("first-time launch")
            self.permissionAlert()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        if !self.initialLoad {
//            self.setupActionController()
//            self.initialLoad = true
//        }
        self.imageViewSize = self.mainImageView.frame.size
        
        if self.mainImageView.image == nil {
            getPhotoFromImageOutlet.backgroundColor = UIColor.lightGrayColor()
            getPhotoFromImageOutlet.titleLabel.text = "Select New Photo"
        }

    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        getPhotoFromImageOutlet.backgroundColor = UIColor.clearColor()
        getPhotoFromImageOutlet.titleLabel.text = ""
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
        } else if segue.identifier == "ShowCamera" {
            let cameraVC = segue.destinationViewController as CameraViewController
            cameraVC.photoDelegate = self
            
        } else if segue.identifier == "ShowFilter" {
            let filterVC = segue.destinationViewController as PhotoViewController
            filterVC.delegate = self
            
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
        
        self.actionController = UIAlertController(title: "Select New Photo", message: "Choose photo source", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        if self.actionController.popoverPresentationController {
            //self.actionController.modalPresentationStyle = UIModalPresentationStyle.Popover
            self.actionController.popoverPresentationController.barButtonItem = self.addPhotoBarButtonOutlet
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

        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            
            let camera2Action = UIAlertAction(title: "Camera 2", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                
                self.checkAuthentication({ (status) -> Void in
                    if status == PHAuthorizationStatus.Authorized {
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.performSegueWithIdentifier("ShowCamera", sender: self)
                        })
                    }
                })
            })
            self.actionController.addAction(camera2Action)
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

    @IBAction func addPhotoBarButton(sender: UIBarButtonItem) {
        //        self.presentViewController(self.photoPicker, animated: true, completion: nil)
        if self.actionController.popoverPresentationController {
            self.actionController.popoverPresentationController.barButtonItem = self.addPhotoBarButtonOutlet
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
       
        var imageData = UIImageJPEGRepresentation(self.mainImageView.image, 1.0)
        self.mainImageView.image = UIImage(data: imageData)
        UIImageWriteToSavedPhotosAlbum(self.mainImageView.image, nil, nil, nil)

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
    
    func photoTaken(photo: UIImage) -> Void {

        self.mainImageView.image = photo
    }
        
//    @IBOutlet weak var bandwFilterButtonOutlet: UIButton!
    
//    @IBAction func bandwFilterButton(sender: UIButton) {
//        bandwWasClicked = true
//        filter()
//    }
    
//    @IBOutlet weak var sepiaFilterButtonOutlet: UIButton!
    
//    @IBAction func sepiaFilterButton(sender: UIButton) {
//        sepiaWasClicked = true
//        filter()
//    }
    
//    func filter() {
//        
//        var options = PHContentEditingInputRequestOptions()
//        options.canHandleAdjustmentData = {(data : PHAdjustmentData!) -> Bool in
//            // used to share identifiers
//            return data.formatIdentifier == self.adjustmentFormatterIdentifier && data.formatVersion == "1.0"
//        }
//        
//        self.selectedAsset!.requestContentEditingInputWithOptions(
//            options, completionHandler: { (contentEditingInput: PHContentEditingInput!, info:[NSObject : AnyObject]!) -> Void in
//                
//                // grab image, convert to CIImage
//                var url = contentEditingInput.fullSizeImageURL
//                var orientation = contentEditingInput.fullSizeImageOrientation
//                var inputImage = CIImage(contentsOfURL: url).imageByApplyingOrientation(orientation)
//                // also written as
////                var inputImage = CIImage(contentsOfURL: url)
////                inputImage = inputImage.imageByApplyingOrientation(orientation)
//                
//                // create filter, creat output image
//                
//                var filter : CIFilter!
//                
//                if self.bandwWasClicked == true {
////                    filter = CIFilter(name: "CISRGBToneCurveToLinear") //Maps color intensity from the sRGB color space to a linear gamma curve.
////                    filter = CIFilter(name: "CIBloom") //Softens edges and applies a pleasant glow to an image.
////                    filter = CIFilter(name: "CIColorInvert") //Inverts the colors in an image.
////                    filter = CIFilter(name: "CIColorPosterize") //Remaps red, green, and blue color components to the number of brightness values you specify for each color component.
//                    filter = CIFilter(name: "CIPhotoEffectMono") //Applies a preconfigured set of effects that imitate black-and-white photography film with low contrast.
//                    self.bandwWasClicked = false
//                }
//                
//                if self.sepiaWasClicked == true {
//                    filter = CIFilter(name: "CISepiaTone") //Maps the colors of an image to various shades of brown.
//                    self.sepiaWasClicked = false
//                }
//                
//                filter.setDefaults() // necessary?
//                filter.setValue(inputImage, forKey: kCIInputImageKey)
//                var outputImage = filter.outputImage
//                
//                // save
//                var cgImage = self.context.createCGImage(outputImage, fromRect: outputImage.extent())
//                var finalImage = UIImage(CGImage: cgImage)
//                var jpegData = UIImageJPEGRepresentation(finalImage, 0.5) // need to write data to disk // changed from 1.0 to 0.5
//                
//                var adjustmentData = PHAdjustmentData(formatIdentifier: self.adjustmentFormatterIdentifier, formatVersion: "1.0'", data: jpegData)
//                var contentEditingOutput = PHContentEditingOutput(contentEditingInput: contentEditingInput)
//                jpegData.writeToURL(contentEditingOutput.renderedContentURL, atomically: true)
//                contentEditingOutput.adjustmentData = adjustmentData
//                
//                // request change
//                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
//                    
//                    var request = PHAssetChangeRequest(forAsset: self.selectedAsset)
//                    request.contentEditingOutput = contentEditingOutput
//                    
//                    }, completionHandler: {(success: Bool, error: NSError!) -> Void in
//                        
//                        if !success {
//                            println(error.localizedDescription)
//                        }
//                })
//        })
//    }
    
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
    
    func permissionAlert() {

        let permitAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        self.presentViewController(self.alertView, animated: true, completion: nil)
        
        alertView.addAction(permitAction)
    }
    @IBOutlet weak var addFilterOutlet: UIButton!
    
    @IBAction func addFilter(sender: UIButton) {

        self.performSegueWithIdentifier("ShowFilter", sender: self)
        
    }
    
}