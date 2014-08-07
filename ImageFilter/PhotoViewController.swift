//
//  PhotoViewController.swift
//  ImageFilter
//
//  Created by Michael Tirenin on 8/5/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

import UIKit
import Photos

protocol PhotoSelectedDelegate {
    
    func photoSelected(asset : PHAsset) -> Void
}

class PhotoViewController: UIViewController {

    var asset : PHAsset!
    var delegate : PhotoSelectedDelegate?

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var targetSize = CGSize(width: CGRectGetWidth(self.imageView.frame), height: CGRectGetHeight(self.imageView.frame))
        // request the image for the asset
        PHImageManager.defaultManager().requestImageForAsset(self.asset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (result : UIImage!, [NSObject : AnyObject]!) -> Void in
            self.imageView.image = result
        }
    }
    
    @IBAction func selectPhotoButton(sender: UIButton) {
        self.delegate!.photoSelected(self.asset)
        self.navigationController.popToRootViewControllerAnimated(true)
        // look at Alex's code for userSelectedPhoto to implement "loadImageForAsset"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
