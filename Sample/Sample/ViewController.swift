//
//  ViewController.swift
//  Sample
//
//  Created by Arror on 2017/5/14.
//  Copyright © 2017年 Arror. All rights reserved.
//

import UIKit
import MQPhotoBrowser
import Kingfisher

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MQPhotoBrowserDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let images: [UIImage?] = [
        UIImage(named: "photo1"),
        UIImage(named: "photo2"),
        UIImage(named: "photo3"),
        UIImage(named: "photo4"),
        UIImage(named: "photo5"),
        UIImage(named: "photo6"),
        UIImage(named: "photo7"),
        UIImage(named: "photo8"),
        UIImage(named: "photo9")
    ]
    
    let imageURLStrings: [String] = [
        "http://wx1.sinaimg.cn/large/bfc243a3gy1febm7n9eorj20i60hsann.jpg",
        "http://wx3.sinaimg.cn/large/bfc243a3gy1febm7nzbz7j20ib0iek5j.jpg",
        "http://wx1.sinaimg.cn/large/bfc243a3gy1febm7orgqfj20i80ht15x.jpg",
        "http://wx2.sinaimg.cn/large/bfc243a3gy1febm7pmnk7j20i70jidwo.jpg",
        "http://wx3.sinaimg.cn/large/bfc243a3gy1febm7qjop4j20i00hw4c6.jpg",
        "http://wx4.sinaimg.cn/large/bfc243a3gy1febm7rncxaj20ek0i74dv.jpg",
        "http://wx2.sinaimg.cn/large/bfc243a3gy1febm7sdk4lj20ib0i714u.jpg",
        "http://wx4.sinaimg.cn/large/bfc243a3gy1febm7tekewj20i20i4aoy.jpg",
        "http://wx3.sinaimg.cn/large/bfc243a3gy1febm7usmc8j20i543zngx.jpg",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func clearCacheButtonTapped(_ sender: UIBarButtonItem) {
        
        KingfisherManager.shared.cache.clearMemoryCache()
        
        KingfisherManager.shared.cache.calculateDiskCacheSize { size in
            
            KingfisherManager.shared.cache.clearDiskCache {
                
                let alert = UIAlertController(title: "Clear Cache", message: String(format: "%.1f MB", Double(size / 1024 / 1024)), preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuse", for: indexPath) as! SampleCell
        
        cell.image = self.images[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        let inset = layout.sectionInset
        
        let width = floor((collectionView.bounds.width - inset.left - inset.right - layout.minimumLineSpacing) / 2.0)
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        MQPhotoBrowser.show(delegate: self, currentIndex: indexPath.row)
    }
    
    func numberOfPhotosInPhotoBrowser(_ photoBrowser: MQPhotoBrowser) -> Int {
        
        return self.images.count
    }
    
    func photoBrowser(_ photoBrowser: MQPhotoBrowser, placeholderImageAt index: Int) -> UIImage? {
        
        return self.images[index]
    }
    
    func photoBrowser(_ photoBrowser: MQPhotoBrowser, photoURLAt index: Int) -> URL? {
        
        return URL(string: self.imageURLStrings[index])
    }
    
    func photoBrowser(_ photoBrowser: MQPhotoBrowser, longPressWith image: UIImage?, url: URL?) {
        
        print("Share or sava.")
    }
    
    func photoBrowser(_ photoBrowser: MQPhotoBrowser, currentSourceViewFor index: Int) -> UIImageView? {
        
        let indexPath = IndexPath(row: index, section: 0)
        
        if !self.collectionView.indexPathsForVisibleItems.contains(indexPath) {
            
            self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        }
        
        collectionView.layoutIfNeeded()
        
        let cell = self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? SampleCell
        
        return cell?.imageView
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
}

class SampleCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage? {
        didSet {
            self.update(image: self.image)
        }
    }
    
    func update(image: UIImage?) {
        self.imageView.image = image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.image = nil
    }
}

extension UINavigationController {
    
    open override var childViewControllerForStatusBarStyle: UIViewController? {
        
        return self.topViewController
    }
    
    open override var childViewControllerForStatusBarHidden: UIViewController? {
        
        return self.topViewController
    }
}
