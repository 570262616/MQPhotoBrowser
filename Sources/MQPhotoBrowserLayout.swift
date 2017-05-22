import UIKit

class MQPhotoBrowserLayout: UICollectionViewFlowLayout {
    
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
        
        self.minimumLineSpacing = MQPhotoBrowserLayout.layoutMinLineSpacing
        
        self.minimumInteritemSpacing = 0.0
    }
    
    override func prepare() {
        
        super.prepare()
        
        guard let collectionView = self.collectionView else { return }
        
        self.pageWidth = collectionView.bounds.width + self.minimumLineSpacing
        
        self.minPageIndex = 0
        
        self.maxPageIndex = Int((self.collectionViewContentSize.width + self.minimumLineSpacing) / self.pageWidth)
    }
    
    private var pageWidth: CGFloat = 0
    
    private var minPageIndex: Int = 0
    private var maxPageIndex: Int = 0
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let collectionView = self.collectionView else { return .zero }
        
        let nearbyPage = collectionView.contentOffset.x / self.pageWidth
        
        let proposedPage = proposedContentOffset.x / self.pageWidth
        
        let intentIndex: Int = {
            if velocity.x.isLess(than: 0) {
                return max(Int(nearbyPage), self.minPageIndex)
            } else if velocity.x.isGreat(than: 0) {
                return min(Int(nearbyPage) + 1, self.maxPageIndex)
            } else {
                return Int(proposedPage + 0.5)
            }
        }()
        
        return CGPoint(x: CGFloat(intentIndex) * self.pageWidth, y: 0)
    }
}

extension CGFloat {
    
    func isGreat(than other: CGFloat) -> Bool {
        
        return !self.isLessThanOrEqualTo(other)
    }
}
