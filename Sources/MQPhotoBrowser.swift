import UIKit

public protocol MQPhotoBrowserDelegate: class {
    
    func numberOfPhotosInPhotoBrowser(_ photoBrowser: MQPhotoBrowser) -> Int
    
    func photoBrowser(_ photoBrowser: MQPhotoBrowser, longPressWith image: UIImage?, url: URL?)
        
    func photoBrowser(_ photoBrowser: MQPhotoBrowser, placeholderImageAt index: Int) -> UIImage?
    
    func photoBrowser(_ photoBrowser: MQPhotoBrowser, photoURLAt index: Int) -> URL?
    
    func photoBrowser(_ photoBrowser: MQPhotoBrowser, currentSourceViewFor index: Int) -> UIImageView?
}

public class MQPhotoBrowser: UIViewController, MQPhotoBrowserTransitionDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private let adaptor = MQPhotoBrowserAdapter()
    
    public weak var delegate: MQPhotoBrowserDelegate?
    
    public var currentIndex: Int = 0 {
        didSet {
            self.sourceView = self.delegate?.photoBrowser(self, currentSourceViewFor: self.currentIndex)
            if self.pageControl != nil {
                self.pageControl.currentPage = self.currentIndex
            }
        }
    }
    
    weak var sourceView: UIImageView? {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
                oldValue?.isHidden = false
                self.sourceView?.isHidden = true
            }
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self.adaptor
        self.collectionView.dataSource = self.adaptor
        
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        
        self.adaptor.numberOfPhotoBlock = { _ in
            
            return self.delegate?.numberOfPhotosInPhotoBrowser(self) ?? 0
        }
        
        self.adaptor.currentIndexBlock = { _, index in
            
            guard self.currentIndex != index else { return }
            
            self.currentIndex = index
        }
        
        self.adaptor.updateCellBlock = { _, index in
            
            let url = self.delegate?.photoBrowser(self, photoURLAt: index)
            let img = self.delegate?.photoBrowser(self, placeholderImageAt: index)
            
            return (img, url)
        }
        
        self.adaptor.photoCellSingleTapAction = { [weak self] _ in
            
            self?.dismiss(completion: { _ in
                
                self?.sourceView?.isHidden = false
            })
        }
        
        self.adaptor.photoCellLongPressAction = { _, image, url in
            
            self.delegate?.photoBrowser(self, longPressWith: image, url: url)
        }
        
        let transition = self.transition
        
        self.adaptor.photoCellUpdateScale = { _, scale, animated in
            
            let alpha = scale * scale
            
            if animated {
                
                UIView.animate(withDuration: 0.25) { transition.dimmingView?.alpha = alpha }
                
            } else {
                
                transition.dimmingView?.alpha = alpha
            }
        }
        
        self.view.layoutIfNeeded()
        
        self.collectionView.scrollToItem(at: IndexPath(item: self.currentIndex, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    public override var shouldAutorotate: Bool { return false }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
        
        self.pageControl.numberOfPages = self.delegate?.numberOfPhotosInPhotoBrowser(self) ?? 0
        self.pageControl.currentPage = self.currentIndex
    }
}

extension MQPhotoBrowser {
    
    private func makeScaleImageView() -> UIImageView {
        
        let imgView = UIImageView()
        
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        
        return imgView
    }
    
    func animatorForShow(dimmingView: UIView, transitionView: UIView) -> MQPhotoBrowserAnimator {
        
        let imgView = self.makeScaleImageView()
        
        return MQPhotoBrowserAnimator(duration: 0.35).prepare { [weak self] _ in
            
            guard let strongSelf = self else { return }
            
            strongSelf.view.isHidden = true
            
            dimmingView.alpha = 0.0
            
            let sourceView = strongSelf.sourceView
            
            imgView.image = sourceView?.image
            
            imgView.frame = sourceView?.convert(sourceView?.frame ?? .zero, to: transitionView) ?? .zero
            
            transitionView.addSubview(imgView)
            
        }.transition { _ in
            
            guard let size = imgView.image?.size, !size.width.isLessThanOrEqualTo(0.0) else { return }
            
            let bounds = transitionView.bounds
            
            let height = bounds.width * size.height / size.width
            
            imgView.bounds = CGRect(x: 0, y: 0, width: bounds.width, height: height)
            
            imgView.center = transitionView.center
            
            dimmingView.alpha = 1.0
                
        }.end({ [weak self] isFinish in
            
            self?.view.isHidden = false
            
            imgView.removeFromSuperview()
        })
    }
    
    func animatorForDismiss(dimmingView: UIView, transitionView: UIView) -> MQPhotoBrowserAnimator {
        
        let imgView = self.makeScaleImageView()
        
        return MQPhotoBrowserAnimator(duration: 0.35).prepare { [weak self] _ in
            
            guard let strongSelf = self else { return }
            
            strongSelf.view.isHidden = true
            
            let fromImageView = (strongSelf.collectionView.visibleCells.first as? MQPhotoCell)?.imageView
            
            imgView.image = fromImageView?.image
            
            imgView.frame = fromImageView?.convert(fromImageView?.bounds ?? .zero, to: transitionView) ?? .zero
            
            transitionView.addSubview(imgView)
            
        }.transition { [weak self] _ in
            
            let sourceView = self?.sourceView
            
            if let frame = sourceView?.convert(sourceView?.frame ?? .zero, to: transitionView) {
                
                imgView.frame = frame
                
            } else {
                
                imgView.alpha = 0.0
            }
            
            dimmingView.alpha = 0.0
                
        }.end({ [weak self] _ in
            
            imgView.removeFromSuperview()
            
            self?.view.isHidden = true
        })
    }
}

extension MQPhotoBrowser {
    
    private static func makePhotoBrowser() -> MQPhotoBrowser {
        
        guard
            let photoBrowserVC = UIStoryboard(name: "MQPhotoBrowser", bundle: MQBundle.main).instantiateInitialViewController() as? MQPhotoBrowser else {
                
                fatalError("Can't load photo browser view controller from story board.")
        }
        
        return photoBrowserVC
    }
    
    public static func show(delegate: MQPhotoBrowserDelegate?, currentIndex: Int) {
        
        let vc = self.makePhotoBrowser()
        
        guard let count = delegate?.numberOfPhotosInPhotoBrowser(vc), (0..<count).contains(currentIndex) else { return }
        
        vc.delegate = delegate
        
        vc.currentIndex = currentIndex
        
        vc.show { _ in }
    }
}
