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
    
    let actionController = UIAlertController(title: "Choose Photo Source", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    @IBOutlet weak var mainImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.photoPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.photoPicker.allowsEditing = true
        self.photoPicker.delegate = self
        
        self.setupActionController()
        
        mainImageView.layer.borderColor = UIColor.grayColor().CGColor
        mainImageView.layer.borderWidth = 1.5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupActionController() {
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            
        })
            
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            self.presentViewController(self.photoPicker, animated: true, completion: nil)
        })
        self.actionController.addAction(cameraAction)
        self.actionController.addAction(photoLibraryAction)
    }

    @IBAction func getPhoto(sender: UIButton) {
     
//        self.presentViewController(self.photoPicker, animated: true, completion: nil)
        self.presentViewController(self.actionController, animated: true, completion: nil)
    }
    
    @IBAction func getPhotoFromImageButton(sender: UIButton) {
        
//        self.presentViewController(self.photoPicker, animated: true, completion: nil)
        self.presentViewController(self.actionController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        
        var editedImage = info[UIImagePickerControllerEditedImage] as UIImage
        self.mainImageView.image = editedImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

