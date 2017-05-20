import UIKit

public protocol MQPhotoBrowerDelegate: class {
    
    func photoBrower(_ photoBrower: MQPhotoBrower, longPressWith image: UIImage?, url: URL?)
    
    func numberOfPhotosInPhotoBrower(_ photoBrower: MQPhotoBrower) -> Int
    
    func photoBrower(_ photoBrower: MQPhotoBrower, photoAt index: Int) -> UIImage?
    
    func photoBrower(_ photoBrower: MQPhotoBrower, photoURLAt index: Int) -> URL?
    
    func photoBrower(_ photoBrower: MQPhotoBrower, currentSourceViewFor index: Int) -> UIImageView?
}

public class MQPhotoBrower: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private let adaptor = MQPhotoBrowerAdapter()
    
    public weak var delegate: MQPhotoBrowerDelegate?
    
    public var currentIndex: Int = 0 {
        didSet {
            self.sourceView = self.delegate?.photoBrower(self, currentSourceViewFor: self.currentIndex)
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
            
            return self.delegate?.numberOfPhotosInPhotoBrower(self) ?? 0
        }
        
        self.adaptor.currentIndexBlock = { _, index in
            
            guard self.currentIndex != index else { return }
            
            self.currentIndex = index
        }
        
        self.adaptor.updateCellBlock = { _, index in
            
            let image = self.delegate?.photoBrower(self, photoAt: index)
            
            let url = self.delegate?.photoBrower(self, photoURLAt: index)
            
            return (image, url)
        }
        
        self.adaptor.photoCellSingleTapAction = { _ in
            
            self.dismiss(animated: true) { self.sourceView?.isHidden = false }
        }
        
        self.adaptor.photoCellLongPressAction = { _, image, url in
            
            self.delegate?.photoBrower(self, longPressWith: image, url: url)
        }
        
        self.adaptor.photoCellUpdateScale = { _, scale, animated in
            
            let controller = self.presentationController as? MQPresentationController
            
            let alpha = scale * scale
            
            if animated {
                
                UIView.animate(withDuration: 0.25) { controller?.dimmingView?.alpha = alpha }
                
            } else {
                
                controller?.dimmingView?.alpha = alpha
            }
        }
        
        self.view.layoutIfNeeded()
        
        self.collectionView.scrollToItem(at: IndexPath(item: self.currentIndex, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    public override var shouldAutorotate: Bool { return false }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
        
        self.pageControl.numberOfPages = self.delegate?.numberOfPhotosInPhotoBrower(self) ?? 0
        self.pageControl.currentPage = self.currentIndex
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle { return self.presentingViewController?.preferredStatusBarStyle ?? .default }
}

extension MQPhotoBrower {
    
    public static func makePhotoBrower() -> MQPhotoBrower {
        
        guard
            let photoBrowerVC = UIStoryboard(name: "MQPhotoBrower", bundle: MQBundle.main).instantiateInitialViewController() as? MQPhotoBrower else {
                
                fatalError("Can't load MQPhotoBrowerViewController from story board.")
        }
        
        return photoBrowerVC
    }
    
    @discardableResult
    public static func show<HostViewController: UIViewController>(by hostVC: HostViewController, currentIndex: Int) -> MQPhotoBrower where HostViewController: MQPhotoBrowerDelegate {
        
        let vc = self.makePhotoBrower()
        
        guard (0..<hostVC.numberOfPhotosInPhotoBrower(vc)).contains(currentIndex) else { return vc }
        
        vc.delegate = hostVC
        
        vc.currentIndex = currentIndex
        
        vc.modalPresentationStyle = .custom
        
        vc.transitioningDelegate = vc
        
        hostVC.present(vc, animated: true, completion: nil)
        
        return vc
    }
}