//
//  GridViewController.swift
//  ImageFilter
//
//  Created by Michael Tirenin on 8/5/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

import UIKit
import Photos

class GridViewController: UIViewController, UICollectionViewDataSource, PhotoSelectedDelegate {

    var assetsFetchResult : PHFetchResult!
    var imageManager : PHCachingImageManager!
    var assetGridThumbnailSize : CGSize!
    
    var delegate : PhotoSelectedDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.imageManager = PHCachingImageManager()
        
        self.navigationItem.title = "Photos"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var scale = UIScreen.mainScreen().scale
        var flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        var cellSize = flowLayout.itemSize
        self.assetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale)
    }

    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "ShowPhoto" {
            var cell = sender as PhotoCell
            var indexPath = self.collectionView.indexPathForCell(cell)
            let photoVC = segue.destinationViewController as PhotoViewController
            photoVC.asset = self.assetsFetchResult[indexPath.item] as PHAsset
            photoVC.delegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return self.assetsFetchResult.count
    }
    
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as PhotoCell
        
        var currentTag = cell.tag + 1
        cell.tag = currentTag
        
        var asset = self.assetsFetchResult[indexPath.item] as PHAsset
    
        self.imageManager.requestImageForAsset(asset, targetSize: self.assetGridThumbnailSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (result: UIImage!, [NSObject : AnyObject]!) -> Void in
            
            if cell.tag == currentTag {
                cell.imageView.image = result
            }
        }
        return cell
    }
    
    func photoSelected(asset: PHAsset) -> Void {
        self.delegate!.photoSelected(asset)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
