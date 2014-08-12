//
//  CameraViewController.swift
//  ImageFilter
//
//  Created by Michael Tirenin on 8/10/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import CoreVideo
import ImageIO
import QuartzCore
import CoreMedia
import AssetsLibrary

protocol PhotoTakenDelegate {
    
    func photoTaken(photo: UIImage) -> Void
}

class CameraViewController: UIViewController {

    // capture photo from AVCaptureSession
    var stillImageOutput = AVCaptureStillImageOutput()
    
    @IBOutlet weak var cameraView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    
//    var asset : PHAsset!
    var photo : UIImage?
    
    var photoDelegate : PhotoTakenDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.borderColor = UIColor.blackColor().CGColor
        imageView.layer.borderWidth = 1.5

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // create capture session
        var captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        // set preview layer
        var layer = self.cameraView.layer
        var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer.frame = self.cameraView.frame
//        self.cameraView.layer.addSublayer(previewLayer)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer.frame = self.cameraView.bounds
        self.cameraView.layer.addSublayer(previewLayer)
        
//        self.view.bringSubviewToFront(imageView)
        
        // set input device
        
        var device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error : NSError?
        var input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error) as AVCaptureDeviceInput
        
        if error != nil {
            // error if input device doesn't work
            println(error!.localizedDescription)
        } else {
            captureSession.addInput(input)
            
            // create output
            var outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            self.stillImageOutput.outputSettings = outputSettings
            captureSession.addOutput(self.stillImageOutput)
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    @IBAction func takePhoto(sender: UIButton) {
        
        var videoConnection : AVCaptureConnection?
        
        for connection in self.stillImageOutput.connections {
            if let cameraConnection = connection as? AVCaptureConnection {
                for port in cameraConnection.inputPorts {
                    
                    if let videoPort = port as? AVCaptureInputPort {
                        if videoPort.mediaType == AVMediaTypeVideo {
                            videoConnection = cameraConnection
                        }
                    }
                }
            }
        }
        
        self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (buffer, error) -> Void in
            
            var data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
            
                // put on main thread
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                
                var image = UIImage(data: data)
                self.imageView.image = image
            })
        })
    }
    
    @IBAction func takePhotoBarButton(sender: UIBarButtonItem) -> Void {
        
        var videoConnection : AVCaptureConnection?
        
        for connection in self.stillImageOutput.connections {
            if let cameraConnection = connection as? AVCaptureConnection {
                for port in cameraConnection.inputPorts {
                    
                    if let videoPort = port as? AVCaptureInputPort {
                        if videoPort.mediaType == AVMediaTypeVideo {
                            videoConnection = cameraConnection
                        }
                    }
                }
            }
        }
        
        self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (buffer, error) -> Void in
            
            var data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
            
            // put on main thread
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                
                var image = UIImage(data: data)
                self.imageView.image = image
            })
        })
        
        self.photo = self.imageView.image
    }
    
    @IBAction func savePhotoBarButton(sender: UIBarButtonItem) {
        
        var imageData = UIImageJPEGRepresentation(self.imageView.image, 1.0)
        self.imageView.image = UIImage(data: imageData)
        UIImageWriteToSavedPhotosAlbum(self.imageView.image, nil, nil, nil)
        
//        let targetSize = CGSize(width: CGRectGetWidth(self.imageView.frame), height: CGRectGetHeight(self.imageView.frame))
//        // request the image for the asset
//        PHImageManager.defaultManager().requestImageForAsset(self.asset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (result : UIImage!, [NSObject : AnyObject]!) -> Void in
//            self.imageView.image = result
//        }
        
        self.photoDelegate!.photoTaken(self.imageView.image)
    
        self.navigationController.popToRootViewControllerAnimated(true)
    }
}