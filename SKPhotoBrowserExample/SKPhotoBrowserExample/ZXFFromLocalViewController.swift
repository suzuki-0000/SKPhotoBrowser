//
//  ZXFFromLocalViewController.swift
//  SKPhotoBrowserExample
//
//  Created by YT. on 2019/7/1.
//  Copyright © 2019 suzuki_keishi. All rights reserved.
//

import UIKit
import SKPhotoBrowser

class ZXFFromLocalViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var images = [SKPhotoProtocol]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }

}

extension ZXFFromLocalViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exampleCollectionViewCell", for: indexPath) as? ExampleCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.exampleImageView.image = UIImage(named: "image\((indexPath as NSIndexPath).row % 10).jpg")
        return cell
    }
    
}

extension ZXFFromLocalViewController: SKPhotoBrowserDelegate {
    
}
