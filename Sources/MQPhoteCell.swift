import UIKit
import Kingfisher

class MQPhotoCell: UICollectionViewCell, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    let imageView = UIImageView()
    
    var photoInfo: (UIImage?, URL?)? {
        didSet {
            self.updateWithPhotoInfo(self.photoInfo)
        }
    }
    
    private func updateLayout() {
        
        self.layoutIfNeeded()
        
        self.scrollView.setZoomScale(1.0, animated: false)
        
        let size: CGSize = {
            
            guard let image = self.imageView.image, !image.size.width.isLessThanOrEqualTo(0.0) else { return .zero }
            
            let width = self.scrollView.bounds.width
            
            let scale = image.size.height / image.size.width
            
            return CGSize(width: width, height: width * scale)
        }()
        
        self.scrollView.maximumZoomScale = {
            
            let scrollMaxZoomScale = self.scrollView.maximumZoomScale
            
            guard size != .zero, (size.height * scrollMaxZoomScale).isLess(than: self.scrollView.bounds.height) else { return scrollMaxZoomScale }
            
            return self.scrollView.bounds.height / size.height
        }()
        
        let y = size.height.isLess(than: self.scrollView.bounds.height) ? (self.scrollView.bounds.height - size.height) / 2.0 : 0
        
        self.imageView.frame = CGRect(x: 0, y: y, width: size.width, height: size.height)
        
        self.scrollView.setZoomScale(1.0, animated: false)
        
        self.progressView.center = self.contentView.center
    }
    
    private let progressView = MQProgressView(frame: .zero)
    
    func updateWithPhotoInfo(_ info: (UIImage?, URL?)?) {
        
        if let imageURL = info?.1 {
            
            self.imageView.kf.setImage(with: imageURL, placeholder: info?.0, options: nil, progressBlock: { [weak self] received, total in
                
                self?.progressView.isHidden = false
                
                let progress = CGFloat(received) / CGFloat(total)
                
                self?.progressView.progress = progress
                
            }, completionHandler: { [weak self] image, _, _, _ in
                
                self?.progressView.isHidden = true
                
                self?.updateLayout()
            })
            
        } else {
            
            self.imageView.image = info?.0
            
            self.updateLayout()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoInfo = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.scrollView.addSubview(self.imageView)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(MQPhotoCell.doubleTapGestureAction(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.contentView.addGestureRecognizer(doubleTapGesture)

        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(MQPhotoCell.singleTapGestureAction(_:)))
        singleTapGesture.require(toFail: doubleTapGesture)
        self.contentView.addGestureRecognizer(singleTapGesture)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(MQPhotoCell.longPressGestureAction(_:)))
        self.contentView.addGestureRecognizer(longPressGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(MQPhotoCell.panGestureAction(_:)))
        panGesture.delegate = self
        self.scrollView.addGestureRecognizer(panGesture)
        
        self.progressView.isHidden = true
        self.contentView.addSubview(self.progressView)
    }
    
    var photoCellSingleTapAction: ((MQPhotoCell) -> Void)?
    
    func singleTapGestureAction(_ sender: UITapGestureRecognizer) {
        
        self.photoCellSingleTapAction?(self)
    }
    
    func doubleTapGestureAction(_ sender: UITapGestureRecognizer) {
        
        if self.scrollView.zoomScale.isEqual(to: 1.0) {
            
            let tapPoint = sender.location(in: self.imageView)
            
            let width = self.scrollView.bounds.width / self.scrollView.maximumZoomScale
            let height = self.scrollView.bounds.height / self.scrollView.maximumZoomScale
            
            let x = tapPoint.x - (width / 2.0)
            let y = tapPoint.y - (height / 2.0)
            
            self.scrollView.zoom(to: CGRect(x: x, y: y, width: width, height: height), animated: true)
            
            self.scrollView.setZoomScale(self.scrollView.maximumZoomScale, animated: true)
            
        } else {
            
            self.scrollView.setZoomScale(1.0, animated: true)
        }
    }
    
    var photoCellLongPressAction: ((MQPhotoCell, UIImage?, URL?) -> Void)?
    
    func longPressGestureAction(_ sender: UILongPressGestureRecognizer) {
        
        switch sender.state {
        case .began:
            self.photoCellLongPressAction?(self, self.photoInfo?.0, self.photoInfo?.1)
        default:
            break
        }
    }

    private var beganBounds: CGRect = .zero
    private var beganCenter: CGPoint = .zero
    
    var photoCellUpdateScale: ((MQPhotoCell, CGFloat, Bool) -> Void)?
    
    func panGestureAction(_ sender: UIPanGestureRecognizer) {
        
        switch sender.state {
        case .began:
            
            self.beganBounds = self.imageView.bounds
            self.beganCenter = self.imageView.center
            
        case .changed:
            
            let offset = sender.translation(in: self.scrollView)
            
            let scale = min(1.0, max(0.3, 1.0 - offset.y / self.scrollView.bounds.height))
            
            let w = self.beganBounds.width * scale
            let h = self.beganBounds.height * scale
            
            let centerX = self.beganCenter.x + offset.x
            let centerY = self.beganCenter.y + offset.y
            
            self.imageView.bounds = CGRect(x: 0.0, y: 0.0, width: w, height: h)
            self.imageView.center = CGPoint(x: centerX, y: centerY)
            
            self.photoCellUpdateScale?(self, scale, false)
            
        case .ended, .cancelled:
            
            if sender.velocity(in: self).y.isLessThanOrEqualTo(0.0) {
                
                self.setImageViewBackToBeginFrame()
                
            } else {
                
                self.photoCellSingleTapAction?(self)
            }
        default:
            
            self.setImageViewBackToBeginFrame()
        }
    }
    
    func setImageViewBackToBeginFrame() {
        
        self.photoCellUpdateScale?(self, 1.0, true)
        
        UIView.animate(withDuration: 0.25) {
            
            self.imageView.bounds = self.beganBounds
            
            self.imageView.center = self.beganCenter
        }
    }
    
    func centerOfContentSize() -> CGPoint {
        
        let x = self.scrollView.contentSize.width / 2.0
        let y = self.scrollView.contentSize.height / 2.0
        
        let xD = self.bounds.width - self.scrollView.contentSize.width
        let yD = self.bounds.height - self.scrollView.contentSize.height
        
        let offsetX = xD.isLessThanOrEqualTo(0.0) ? 0 : xD / 2.0
        let offsetY = yD.isLessThanOrEqualTo(0.0) ? 0 : yD / 2.0
        
        return CGPoint(x: x + offsetX, y: y + offsetY)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { return self.imageView }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        self.imageView.center = self.centerOfContentSize()
    }
}

extension MQPhotoCell: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        
        let v = pan.velocity(in: self)

        if v.y.isLess(than: 0.0) {
            return false
        }

        if abs(v.y).isLess(than: abs(v.x)) {
            return false
        }

        if self.scrollView.contentOffset.y.isLess(than: 0.0) {
            return false
        }
        
        return true
    }
}
