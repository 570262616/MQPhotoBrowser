import UIKit

class MQPhotoBrowerAdapter: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    override init() { super.init() }
    
    var numberOfPhotoBlock: ((MQPhotoBrowerAdapter) -> Int)?
    
    var currentIndexBlock:((MQPhotoBrowerAdapter, Int) -> Void)?
    
    var updateCellBlock: ((MQPhotoBrowerAdapter, Int) -> (UIImage?, URL?))?
    
    var photoCellSingleTapAction: ((MQPhotoCell) -> Void)?
    
    var photoCellLongPressAction: ((MQPhotoCell, UIImage?, URL?) -> Void)?
    
    var photoCellUpdateScale: ((MQPhotoCell, CGFloat, Bool) -> Void)?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.numberOfPhotoBlock?(self) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! MQPhotoCell
        
        cell.photoInfo = self.updateCellBlock?(self, indexPath.row)
        
        cell.photoCellSingleTapAction = self.photoCellSingleTapAction
        
        cell.photoCellLongPressAction = self.photoCellLongPressAction
        
        cell.photoCellUpdateScale = self.photoCellUpdateScale
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionView.bounds.size
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let currentIndex = Int((scrollView.contentOffset.x + scrollView.bounds.width / 2.0) / (scrollView.bounds.width + MQPhotoBrowerLayout.layoutMinLineSpacing))
        
        self.currentIndexBlock?(self, currentIndex)
    }
}
