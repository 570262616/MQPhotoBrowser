import UIKit

class MQPhotoBrowerLayout: UICollectionViewFlowLayout {
    
    static var layoutMinLineSpacing: CGFloat = 30.0
    
    override init() {
        
        super.init()
        
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.initialize()
    }
    
    private func initialize() {
        
        self.scrollDirection = .horizontal
        
        self.minimumLineSpacing = MQPhotoBrowerLayout.layoutMinLineSpacing
        
        self.minimumInteritemSpacing = 0.0
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let collectionView = self.collectionView else { return .zero }
        
        let pageWidth = collectionView.bounds.width + self.minimumLineSpacing
        
        let maxPageIndex = Int((self.collectionViewContentSize.width + self.minimumLineSpacing) / pageWidth)
        
        let intentIndex: Int
        
        let nearbyPage = collectionView.contentOffset.x / pageWidth
        
        let proposedPage = proposedContentOffset.x / pageWidth + 0.5
        
        if velocity.x.isLess(than: 0) {
            intentIndex = max(Int(nearbyPage), 0)
        } else if velocity.x.isGreat(than: 0) {
            intentIndex = min(Int(nearbyPage) + 1, maxPageIndex)
        } else {
            intentIndex = Int(proposedPage)
        }
        
        return CGPoint(x: CGFloat(intentIndex) * pageWidth, y: 0)
    }
}

fileprivate extension CGFloat {
    
    func isGreat(than other: CGFloat) -> Bool {
        
        return !self.isLessThanOrEqualTo(other)
    }
}
