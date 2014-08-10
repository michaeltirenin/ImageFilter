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

class PhotoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate/*, PHPhotoLibraryChangeObserver*/ {
    
    var filterImageSize : CGSize = CGSize(width: 94, height: 94)
    
    var asset : PHAsset!
    
    var delegate : PhotoSelectedDelegate?

    @IBOutlet weak var imageView: UIImageView!
    
// filter
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let adjustmentFormatterIdentifier = "com.ImageFilter.michaeltirenin"
    let adjustmentFormatVersion = "1.0"
    var context = CIContext(options: nil)
    
    var filterThumbnail : UIImage?
    
//    var filterThumbnailSize : CGSize!
    
    var filters = [Filter]()
    
    var filterList = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Filters"
        
        self.setFilters()
        
        self.fetchThumbnailImage()
        
//        self.updateImage()
        
//        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let targetSize = CGSize(width: CGRectGetWidth(self.imageView.frame), height: CGRectGetHeight(self.imageView.frame))
        // request the image for the asset
        PHImageManager.defaultManager().requestImageForAsset(self.asset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (result : UIImage!, [NSObject : AnyObject]!) -> Void in
            self.imageView.image = result
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        self.filterThumbnailSize = self.filterThumbnail!.size
        
    }

// selected image and return to root view
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
        self.filterList = ["Invert", "B&W", "Sepia", "Flat", "Posterize", "Sharpen"]
    }
    
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        
        return self.filters.count
    }
    
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterCell", forIndexPath: indexPath) as FilterCell
        
        let filter = filters[indexPath.item] as Filter
        
        cell.filterLabel.text = filterList[indexPath.item] as String
        
        if self.filterThumbnail != nil {
            cell.filterImageView.image = filterThumbnail
            println("one")
            if filter.thumbnailImage != nil {
                cell.filterImageView.image = filter.thumbnailImage
                println("two")
            } else {
                filter.createFilterThumbnailFromImage(self.filterThumbnail!, completionHandler: { (image) -> Void in
                    cell.filterImageView.image = image
//                    cell.filterImageView.sizeThatFits(self.filterImageSize)
//                    self.collectionView.reloadData()

                    println("three")
                })
            }
        }
        
        return cell
    }
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        
        var options = PHContentEditingInputRequestOptions()
        options.canHandleAdjustmentData = {(data : PHAdjustmentData!) -> Bool in
            // used to share identifiers
            return data.formatIdentifier == self.adjustmentFormatterIdentifier && data.formatVersion == "1.0"
        }
        
        var selectFilter = ((self.filters[indexPath.item] as Filter).name)
        println("did select")

        
        self.asset!.requestContentEditingInputWithOptions(
            options, completionHandler: { (contentEditingInput: PHContentEditingInput!, info:[NSObject : AnyObject]!) -> Void in
                
                // grab image, convert to CIImage
                let url = contentEditingInput.fullSizeImageURL
                let orientation = contentEditingInput.fullSizeImageOrientation
                
                let inputImage = CIImage(contentsOfURL: url)
                inputImage.imageByApplyingOrientation(orientation)
                
                // create filter, creat output image
                //                var filter : CIFilter!
                let filter = CIFilter(name: selectFilter)
                filter.setDefaults()
                filter.setValue(inputImage, forKey: kCIInputImageKey)
                var outputImage = filter.outputImage
                
                // save
                var cgImage = self.context.createCGImage(outputImage, fromRect: outputImage.extent())
                var finalImage = UIImage(CGImage: cgImage)
                var jpegData = UIImageJPEGRepresentation(finalImage, 0.5) // need to write data to disk // changed from 1.0 to 0.5
                
                // check Kirby's post
                
                var adjustmentData = PHAdjustmentData(formatIdentifier: self.adjustmentFormatterIdentifier, formatVersion: "1.0'", data: jpegData)
                var contentEditingOutput = PHContentEditingOutput(contentEditingInput: contentEditingInput)
                jpegData.writeToURL(contentEditingOutput.renderedContentURL, atomically: true)
                contentEditingOutput.adjustmentData = adjustmentData
                
                //                let filterInfo = NSDictionary(object: "CISepiaTone", forKey: "filter")
                //                let saveFilter = NSKeyedArchiver.archivedDataWithRootObject(filterInfo)
                //                let adjustmentData = PHAdjustmentData(formatIdentifier: self.adjustmentFormatterIdentifier, formatVersion: self.adjustmentFormatVersion, data: saveFilter)
                //
                //                var contentEditingOutput = PHContentEditingOutput(contentEditingInput: contentEditingInput)
                //                jpegData.writeToURL(contentEditingOutput.renderedContentURL, atomically: true)
                //                contentEditingOutput.adjustmentData = adjustmentData
                
                // request change
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    
                    var request = PHAssetChangeRequest(forAsset: self.asset)
                    request.contentEditingOutput = contentEditingOutput
                    
                    }, completionHandler: {(success: Bool, error: NSError!) -> Void in
                        
                        if !success {
                            println(error.localizedDescription)
                        } else {
                            println("updated w filter")
                            self.updateImage()
                        }
                })
        })
    }

    
//    func collectionView(collectionView: UICollectionView!, didDeselectItemAtIndexPath indexPath: NSIndexPath!) {
//        
//        self.selectFilter((self.filters[indexPath.item] as Filter).name)
//        println("did select")
//    }
//    
//    func selectFilter(filter: String) {
//        
//        var options = PHContentEditingInputRequestOptions()
//        options.canHandleAdjustmentData = {(data : PHAdjustmentData!) -> Bool in
//            // used to share identifiers
//            return data.formatIdentifier == self.adjustmentFormatterIdentifier && data.formatVersion == "1.0"
//        }
//        
//        self.asset!.requestContentEditingInputWithOptions(
//            options, completionHandler: { (contentEditingInput: PHContentEditingInput!, info:[NSObject : AnyObject]!) -> Void in
//                
//                // grab image, convert to CIImage
//                var url = contentEditingInput.fullSizeImageURL
//                var orientation = contentEditingInput.fullSizeImageOrientation
//                
//                var inputImage = CIImage(contentsOfURL: url)
//                inputImage = inputImage.imageByApplyingOrientation(orientation)
//                
//                // create filter, creat output image
////                var filter : CIFilter!
//                var filter = CIFilter(name: filter)
//                filter.setDefaults()
//                filter.setValue(inputImage, forKey: kCIInputImageKey)
//                var outputImage = filter.outputImage
//                
//                // save
//                var cgImage = self.context.createCGImage(outputImage, fromRect: outputImage.extent())
//                var finalImage = UIImage(CGImage: cgImage)
//                var jpegData = UIImageJPEGRepresentation(finalImage, 0.5) // need to write data to disk // changed from 1.0 to 0.5
//                
//                // check Kirby's post
//                
//                var adjustmentData = PHAdjustmentData(formatIdentifier: self.adjustmentFormatterIdentifier, formatVersion: "1.0'", data: jpegData)
//                var contentEditingOutput = PHContentEditingOutput(contentEditingInput: contentEditingInput)
//                jpegData.writeToURL(contentEditingOutput.renderedContentURL, atomically: true)
//                contentEditingOutput.adjustmentData = adjustmentData
//                
////                let filterInfo = NSDictionary(object: "CISepiaTone", forKey: "filter")
////                let saveFilter = NSKeyedArchiver.archivedDataWithRootObject(filterInfo)
////                let adjustmentData = PHAdjustmentData(formatIdentifier: self.adjustmentFormatterIdentifier, formatVersion: self.adjustmentFormatVersion, data: saveFilter)
////                
////                var contentEditingOutput = PHContentEditingOutput(contentEditingInput: contentEditingInput)
////                jpegData.writeToURL(contentEditingOutput.renderedContentURL, atomically: true)
////                contentEditingOutput.adjustmentData = adjustmentData
//                
//                // request change
//                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
//
//                    var request = PHAssetChangeRequest(forAsset: self.asset)
//                    request.contentEditingOutput = contentEditingOutput
//                    
//                    }, completionHandler: {(success: Bool, error: NSError!) -> Void in
//                        
//                        if !success {
//                            println(error.localizedDescription)
//                        } else {
//                            println("updated w filter")
//                        }
//                })
//        })
//    }

    func fetchThumbnailImage() {
        if self.asset != nil {

            var targetSize = filterImageSize
//            var targetSize = CGSize(width: CGRectGetWidth(self.imageView.frame)/2, height: CGRectGetHeight(self.imageView.frame)/2)
            PHImageManager.defaultManager().requestImageForAsset(self.asset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil, resultHandler: { (result: UIImage!, info: [NSObject : AnyObject]!) -> Void in

                self.filterThumbnail = result
            })

//            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
//
//                self.collectionView.reloadData()
//            })
            println(targetSize)

        }
    }
    
    func updateImage() {

        var targetSize = self.imageView.frame.size
        PHImageManager.defaultManager().requestImageForAsset(self.asset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (result : UIImage!, info : [NSObject : AnyObject]!) -> Void in
            
            self.imageView.image = result
        }
    }

//    func photoLibraryDidChange(changeInstance: PHChange!) {
//        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
//            
//            if self.asset != nil {
//                var changeDetails = changeInstance.changeDetailsForObject(self.asset)
//                println("one")
//                
//                if changeDetails != nil {
//                    self.asset = changeDetails.objectAfterChanges as? PHAsset
//                    println("two")
//                    
//                    if changeDetails.assetContentChanged {
//                        println("three")
//                        self.updateImage()
//                    }
//                }
//            }
//        }
//    }

}
