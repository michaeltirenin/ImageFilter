//
//  Filter.swift
//  ImageFilter
//
//  Created by Michael Tirenin on 8/7/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

import UIKit

class Filter {
    
    var name : String
    var thumbnailImage : UIImage?
    
    init(name: String) {
        self.name = name
    }
    // Jeff's approach
    func createFilterThumbnailFromImage(previewImage: UIImage, completionHandler: (image: UIImage) -> Void) {
        
        var ciImage = CIImage(image: previewImage)
        var filter = CIFilter(name: self.name)
        filter.setDefaults()
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        var outputImage = filter.outputImage
        
        var finalImage = UIImage(CIImage: outputImage)
        completionHandler(image: finalImage)
    }
}
