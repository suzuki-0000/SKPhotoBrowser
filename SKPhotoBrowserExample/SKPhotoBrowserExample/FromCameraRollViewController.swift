//
//  CameraRollCollectionViewController.swift
//  SKPhotoBrowserExample
//
//  Created by K Rummler on 11/03/16.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit
import Photos
import SKPhotoBrowser

class FromCameraRollViewController: UIViewController, SKPhotoBrowserDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private let imageManager = PHCachingImageManager.defaultManager()
    
    private var assets: [PHAsset] = []
    
    private lazy var requestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.deliveryMode = .Opportunistic
        options.resizeMode = .Fast
        
        return options
    }()
    
    private lazy var bigRequestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.deliveryMode = .HighQualityFormat
        options.resizeMode = .Fast
        
        return options
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchAssets()
        collectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return assets.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("exampleCollectionViewCell", forIndexPath: indexPath)
        let asset = assets[indexPath.row]
        
        if let cell = cell as? AssetExampleCollectionViewCell {
            if let id = cell.requestId {
                imageManager.cancelImageRequest(id)
                cell.requestId = nil
            }
            
            cell.requestId = requestImageForAsset(asset, options: requestOptions) { image, requestId in
                if requestId == cell.requestId || cell.requestId == nil {
                    
                    cell.exampleImageView.image = image
                }
            }
        }
    
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ExampleCollectionViewCell else {
            return
        }
        guard let originImage = cell.exampleImageView.image else {
            return
        }
        
        func open(images: [UIImage]) {
            
            let photoImages: [SKPhotoProtocol] = images.map({ return SKPhoto.photoWithImage($0) })
            let browser = SKPhotoBrowser(originImage: cell.exampleImageView.image!, photos: photoImages, animatedFromView: cell)
            
            browser.initializePageIndex(indexPath.row)
            browser.delegate = self
//            browser.bounceAnimation = true
//            browser.displayDeleteButton = true
//            browser.displayAction = false
            self.presentViewController(browser, animated: true, completion: {})
        }
        
        var fetchedImages: [UIImage] = Array<UIImage>(count: assets.count, repeatedValue: UIImage())
        var fetched = 0
        
        assets.forEach { (asset) -> () in
            
            requestImageForAsset(asset, options:bigRequestOptions, completion: { [weak self] (image, requestId) -> () in
                
                if let image = image, index = self?.assets.indexOf(asset) {
                    fetchedImages[index] = image
                }
                fetched += 1
                
                if self?.assets.count == fetched {
                    open(fetchedImages)
                }
            })
        }
    }
    
    private func fetchAssets() {
        
        let options = PHFetchOptions()
        let limit = 8
        
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.Image.rawValue)

        options.fetchLimit = limit
        
        let result = PHAsset.fetchAssetsWithOptions(options)
        let amount = min(result.count, limit)
        self.assets = result.objectsAtIndexes(NSIndexSet(indexesInRange: NSRange(location: 0, length: amount))) as? [PHAsset] ?? []
    }
    
    private func requestImageForAsset(asset: PHAsset, options: PHImageRequestOptions, completion: (image: UIImage?, requestId: PHImageRequestID?) -> ()) -> PHImageRequestID {
        
        let scale = UIScreen.mainScreen().scale
        let targetSize: CGSize
        
        if options.deliveryMode == .HighQualityFormat {
            targetSize = CGSize(width: 600 * scale, height: 600 * scale)
        } else {
            targetSize = CGSize(width: 182 * scale, height: 182 * scale)
        }
        
        requestOptions.synchronous = false
        
        // Workaround because PHImageManager.requestImageForAsset doesn't work for burst images
        if asset.representsBurst {
            return imageManager.requestImageDataForAsset(asset, options: options) { data, _, _, dict in
                let image = data.flatMap { UIImage(data: $0) }
                let requestId = dict?[PHImageResultRequestIDKey] as? NSNumber
                completion(image: image, requestId: requestId?.intValue)
            }
        } else {
            return imageManager.requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFill, options: options) { image, dict in
                let requestId = dict?[PHImageResultRequestIDKey] as? NSNumber
                completion(image: image, requestId: requestId?.intValue)
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

class AssetExampleCollectionViewCell: ExampleCollectionViewCell {
    var requestId: PHImageRequestID?
}
