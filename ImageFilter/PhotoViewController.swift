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

class PhotoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PHPhotoLibraryChangeObserver {

    var asset : PHAsset!
    
    var delegate : PhotoSelectedDelegate?

    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var filterImageView: UIImageView!
// filter
    var imageViewSize : CGSize!
    var selectedAsset : PHAsset?

    @IBOutlet weak var collectionView: UICollectionView!
    
    let adjustmentFormatterIdentifier = "com.ImageFilter.michaeltirenin"
    var context = CIContext(options: nil)
    
    var filterThumbnail : UIImage?
    
    var filters = [Filter]()
//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Filters"
        
        self.selectedAsset = asset
        self.setFilters()
        self.fetchThumbnailImage()
        
        self.updateImage()
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let targetSize = CGSize(width: CGRectGetWidth(self.imageView.frame), height: CGRectGetHeight(self.imageView.frame))
//        let targetSize = CGSize(width: 110, height: 110)
        // request the image for the asset
        PHImageManager.defaultManager().requestImageForAsset(self.asset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (result : UIImage!, [NSObject : AnyObject]!) -> Void in
            self.imageView.image = result
        }
    }
    
    @IBAction func selectPhotoButton(sender: UIButton) {
        self.delegate!.photoSelected(self.asset)
        self.navigationController.popToRootViewControllerAnimated(true)
        // look at Alex's example for userSelectedPhoto to implement "loadImageForAsset" (remove lag)
    }
    
// filter collection view
    
    func setFilters() {
        let invert = Filter(name: "CIColorInvert")
        let bandw = Filter(name: "CIPhotoEffectMono")
        let sepia = Filter(name: "CISepiaTone")
        let flat = Filter(name: "CISRGBToneCurveToLinear")
        let posterize = Filter(name: "CIColorPosterize")
        let sharpen = Filter(name: "CIUnsharpMask")

        self.filters = [invert, bandw, sepia, flat, posterize, sharpen]
    }
    
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        
        return self.filters.count
    }
    
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterCell", forIndexPath: indexPath) as FilterCell
        
        let filter = filters[indexPath.item] as Filter
        
        println(filter)

        if self.filterThumbnail != nil {
            cell.filterImageView.image = filterThumbnail
            if filter.thumbnailImage != nil {
                cell.filterImageView.image = filter.thumbnailImage
            } else {
                filter.createFilterThumbnailFromImage(self.filterThumbnail!, completionHandler: { (image) -> Void in
                    cell.filterImageView.image = image
                })
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView!, didDeselectItemAtIndexPath indexPath: NSIndexPath!) {
        
        var filter = self.filters[indexPath.item] as Filter
        
        self.filter(filter.name)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func filter(filter: String) {
        
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
                
                // create filter, creat output image
//                var filter : CIFilter!
                var filter = CIFilter(name: filter)
                
//                filter = CIFilter(name: "CISRGBToneCurveToLinear") //Maps color intensity from the sRGB color space to a linear gamma curve.
//                filter = CIFilter(name: "CIBloom") //Softens edges and applies a pleasant glow to an image.
//                filter = CIFilter(name: "CIColorInvert") //Inverts the colors in an image.
//                filter = CIFilter(name: "CIColorPosterize") //Remaps red, green, and blue color components to the number of brightness values you specify for each color component.
//                filter = CIFilter(name: "CIPhotoEffectMono") //Applies a preconfigured set of effects that imitate black-and-white photography film with low contrast.
//                filter = CIFilter(name: "CISepiaTone") //Maps the colors of an image to various shades of brown.

                filter.setDefaults()
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
    
    func fetchThumbnailImage() {
        if self.selectedAsset != nil {
            let targetSize = CGSize(width: CGRectGetWidth(self.imageView.frame), height: CGRectGetHeight(self.imageView.frame))
            PHImageManager.defaultManager().requestImageForAsset(self.selectedAsset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil, resultHandler: { (result: UIImage!, info: [NSObject : AnyObject]!) -> Void in

                self.filterThumbnail = result
            })
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                
                self.collectionView.reloadData()
            })
        }
    }
    
    func updateImage() {
        
        var targetSize = self.imageView.frame.size
        PHImageManager.defaultManager().requestImageForAsset(self.selectedAsset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (result : UIImage!, info : [NSObject : AnyObject]!) -> Void in
            
            self.imageView.image = result
        }
    }
//check on this
    func photoLibraryDidChange(changeInstance: PHChange!) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            
            if self.selectedAsset != nil {
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

}
