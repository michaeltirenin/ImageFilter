//
//  ViewController.swift
//  ImageFilter
//
//  Created by Michael Tirenin on 8/4/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let photoPicker = UIImagePickerController()
    let cameraPicker = UIImagePickerController()
    let cancelPicker = UIImagePickerController()
    
    @IBOutlet weak var photoButtonOutlet: UIButton!
    
    @IBOutlet weak var getPhotoFromImageOutlet: UIButton!
    
    @IBOutlet weak var mainImageView: UIImageView!
    
    let alertView = UIAlertController(title: "NOTE", message: "Message", preferredStyle: UIAlertControllerStyle.Alert)
    
    let actionController = UIAlertController(title: "Choose Photo Source", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    var initialLoad = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
//        self.alertView = UIAlertView(title: "test", message: "test2", delegate: AnyObject!, cancelButtonTitle: "OK")
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        if !self.initialLoad {
            self.setupActionController()
            self.initialLoad = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupActionController() {
        
        println("setting up action controller")
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            
                //self.presentViewController(self.alertView, animated: true, completion: nil)
                self.presentViewController(self.cameraPicker, animated: true, completion: nil)
            })
            self.actionController.addAction(cameraAction)
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            self.presentViewController(self.photoPicker, animated: true, completion: nil)
        })
        
        self.actionController.addAction(photoLibraryAction)

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
            self.actionController.popoverPresentationController.sourceRect = CGRect(x: 100, y: 200, width: 0, height: 0)
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
}