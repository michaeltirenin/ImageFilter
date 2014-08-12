//
//  FilteredImageView.swift
//  ImageFilter
//
//  Created by Michael Tirenin on 8/12/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

import UIKit

@IBDesignable class FilteredImageView: UIImageView {

    // John's example
    var sepiaFilter = CIFilter(name: "CISepiaTone")
    
    @IBInspectable var sepiaIntensity : CGFloat = 0 {
        didSet {
            sepiaFilter.setValue(self.coreImageBackedImage(), forKey: kCIInputImageKey)
            sepiaFilter.setValue(sepiaIntensity, forKey: kCIInputIntensityKey)
            self.image = UIImage(CIImage: sepiaFilter.outputImage)
        }
    }
    
//    var bloomFilter = CIFilter(name: "CIBloom")
//    
//    @IBInspectable var bloom : CGFloat = 1.0 {
//        didSet {
//            bloomFilter.setValue(self.coreImageBackedImage(), forKey: kCIInputImageKey)
//            bloomFilter.setValue(bloom, forKey: kCIInputIntensityKey)
//            bloomFilter.setValue(bloom, forKey: kCIInputRadiusKey)
//            self.image = UIImage(CIImage: bloomFilter.outputImage)
//        }
//    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clearColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    func coreImageBackedImage() -> CIImage {
        let ciImage = CIImage(CGImage: self.image.CGImage)
        return ciImage
    }
}
