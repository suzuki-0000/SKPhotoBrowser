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
    fileprivate let imageManager = PHCachingImageManager.default()
    fileprivate var assets: [PHAsset] = []
    
    fileprivate lazy var requestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        
        return options
    }()
    
    fileprivate lazy var bigRequestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        
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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return assets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exampleCollectionViewCell", for: indexPath)
        let asset = assets[(indexPath as NSIndexPath).row]
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ExampleCollectionViewCell else {
            return
        }
        guard let originImage = cell.exampleImageView.image else {
            return
        }
        
        func open(_ images: [UIImage]) {
            let photoImages: [SKPhotoProtocol] = images.map({ return SKPhoto.photoWithImage($0) })
            let browser = SKPhotoBrowser(originImage: cell.exampleImageView.image!, photos: photoImages, animatedFromView: cell)
            browser.initializePageIndex(indexPath.row)
            browser.delegate = self
//            browser.displayDeleteButton = true
//            browser.displayAction = false
            self.present(browser, animated: true, completion: {})
        }
        
        var fetchedImages: [UIImage] = [UIImage](repeating: UIImage(), count: assets.count)
        var fetched = 0
        
        assets.forEach { (asset) -> Void in
            
            _ = requestImageForAsset(asset, options: bigRequestOptions, completion: { [weak self] (image, _) -> Void in
                
                if let image = image, let index = self?.assets.firstIndex(of: asset) {
                    fetchedImages[index] = image
                }
                fetched += 1
                
                if self?.assets.count == fetched {
                    open(fetchedImages)
                }
            })
        }
    }
    
    fileprivate func fetchAssets() {
        
        let options = PHFetchOptions()
        let limit = 8
        
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)

        options.fetchLimit = limit
        
        let result = PHAsset.fetchAssets(with: options)
        let amount = min(result.count, limit)
        self.assets = result.objects(at: IndexSet(integersIn: Range(NSRange(location: 0, length: amount)) ?? 0..<0))
    }
    
    fileprivate func requestImageForAsset(_ asset: PHAsset, options: PHImageRequestOptions, completion: @escaping (_ image: UIImage?, _ requestId: PHImageRequestID?) -> Void) -> PHImageRequestID {
        
        let scale = UIScreen.main.scale
        let targetSize: CGSize
        
        if options.deliveryMode == .highQualityFormat {
            targetSize = CGSize(width: 600 * scale, height: 600 * scale)
        } else {
            targetSize = CGSize(width: 182 * scale, height: 182 * scale)
        }
        
        requestOptions.isSynchronous = false
        
        // Workaround because PHImageManager.requestImageForAsset doesn't work for burst images
        if asset.representsBurst {
            return imageManager.requestImageData(for: asset, options: options) { data, _, _, dict in
                let image = data.flatMap { UIImage(data: $0) }
                let requestId = dict?[PHImageResultRequestIDKey] as? NSNumber
                completion(image, requestId?.int32Value)
            }
        } else {
            return imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, dict in
                let requestId = dict?[PHImageResultRequestIDKey] as? NSNumber
                completion(image, requestId?.int32Value)
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

class AssetExampleCollectionViewCell: ExampleCollectionViewCell {
    var requestId: PHImageRequestID?
}
