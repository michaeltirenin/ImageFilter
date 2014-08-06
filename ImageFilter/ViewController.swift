//
//  ViewController.swift
//  ImageFilter
//
//  Created by Michael Tirenin on 8/4/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, PhotoSelectedDelegate {
    
    let photoPicker = UIImagePickerController()
    let cameraPicker = UIImagePickerController()
    let cancelPicker = UIImagePickerController()
    var imageViewSize : CGSize!
    var actionController = UIAlertController(title: "Title", message: "Message", preferredStyle: UIAlertControllerStyle.Alert)

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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        if !self.initialLoad {
//            self.setupActionController()
//            self.initialLoad = true
//        }
        self.imageViewSize = self.mainImageView.frame.size
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "ShowGrid" {
            let gridVC = segue.destinationViewController as GridViewController
            // fetch all assets
            gridVC.assetsFetchResult = PHAsset.fetchAssetsWithOptions(nil)
            gridVC.delegate = self
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
        
        let cameraAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {( action: UIAlertAction!) -> Void in
            //present the camera picker
            //self.presentViewController(self.actionController, animated: true, completion: nil)
            
        })
        let photoAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: {(action : UIAlertAction!) -> Void in
            //present the photo library
            self.performSegueWithIdentifier("ShowGrid", sender: self)
        })
        self.actionController.addAction(cameraAction)
        self.actionController.addAction(photoAction)

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
//        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
//            self.dismissViewControllerAnimated(true, completion: nil)
//        })
//        
//        self.actionController.addAction(cancelAction)
    }
    
    @IBAction func getPhotoButton(sender: UIButton) {
        
////        self.presentViewController(self.photoPicker, animated: true, completion: nil)
//        if self.actionController.popoverPresentationController {
//            self.actionController.popoverPresentationController.sourceView = self.photoButtonOutlet
////            self.actionController.popoverPresentationController.sourceRect =
//        }
        self.presentViewController(self.actionController, animated: true, completion: nil)
    }
    
    @IBAction func getPhotoFromImageButton(sender: UIButton) {
        
////        self.presentViewController(self.photoPicker, animated: true, completion: nil)
//        if self.actionController.popoverPresentationController {
//            self.actionController.popoverPresentationController.sourceView = self.getPhotoFromImageOutlet
//            self.actionController.popoverPresentationController.sourceRect = CGRect(x: 100, y: 200, width: 0, height: 0)
//        }
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
        var targetSize = CGSize(width: CGRectGetWidth(self.mainImageView.frame), height: CGRectGetHeight(self.mainImageView.frame))
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
            self.mainImageView.image = image
        }
    }
}