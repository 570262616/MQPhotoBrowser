import UIKit

class MQPhotoBrowerTransition {
    
    private class MQPhotoBrowerWindow: UIWindow {
        
        let dimmingView = UIView()
        
        let transitionView = UIView()
        
        override init(frame: CGRect) {
            
            super.init(frame: frame)
            
            self.dimmingView.frame = CGRect(origin: .zero, size: frame.size)
            
            self.dimmingView.backgroundColor = .black
            
            self.dimmingView.alpha = 1.0
            
            self.addSubview(self.dimmingView)
            
            self.transitionView.frame = UIScreen.main.bounds
            
            self.transitionView.backgroundColor = .clear
            
            self.addSubview(self.transitionView)
            
            self.windowLevel = UIWindowLevelStatusBar + 1.0
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    private init() { self.window = nil }
    
    private var window: MQPhotoBrowerTransition.MQPhotoBrowerWindow?
    
    static let shared = MQPhotoBrowerTransition()
    
    private func makeFullScreenWindow() -> MQPhotoBrowerWindow {
        
        let screenSize = UIScreen.main.bounds.size
        
        let frame = CGRect(origin: .zero, size: CGSize(width: screenSize.width, height: screenSize.height + 1.0))
        
        return MQPhotoBrowerTransition.MQPhotoBrowerWindow(frame: frame)
    }
    
    func updateDimmingViewAlpha(_ alpha: CGFloat) {
        
        self.window?.dimmingView.alpha = alpha
    }
    
    func makeScaleImageView() -> UIImageView {
        
        let imgView = UIImageView()
        
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        
        return imgView
    }
    
    func show(photoBrower: MQPhotoBrower, completion: @escaping (Bool) -> Void) {
        
        let window = self.makeFullScreenWindow()
        window.rootViewController = photoBrower
        window.makeKeyAndVisible()
        self.window = window
        
        let imageView = self.makeScaleImageView()
        
        MQPhotoBrowerAnimator().prepare { [weak self] _ in
            
            guard let strongSelf = self else { return }
            
            photoBrower.view.isHidden = true
            
            strongSelf.window?.dimmingView.alpha = 0.0
            
            let sourceView = photoBrower.sourceView
            
            imageView.image = sourceView?.image
            imageView.frame = sourceView?.convert(sourceView?.frame ?? .zero, to: window.transitionView) ?? .zero
            
            window.transitionView.addSubview(imageView)
            
        }.transition { [weak self] _ in
            
            guard
                let strongSelf = self,
                let size = imageView.image?.size, !size.width.isLessThanOrEqualTo(0.0) else {
                    
                    return
            }
            
            let bounds = window.transitionView.bounds
            
            let height = bounds.width * size.height / size.width
            
            imageView.bounds = CGRect(x: 0, y: 0, width: bounds.width, height: height)
            
            imageView.center = window.transitionView.center
            
            strongSelf.window?.dimmingView.alpha = 1.0
                
        }.end { isFinish in
            
            photoBrower.view.isHidden = false
            
            imageView.removeFromSuperview()
            
            completion(isFinish)
                
        }.perform()
    }
    
    func dismiss(photoBrower: MQPhotoBrower, completion: @escaping (Bool) -> Void) {
        
        guard let window = self.window else { return }
        
        let imageView = self.makeScaleImageView()
        
        MQPhotoBrowerAnimator().prepare { _ in
            
            photoBrower.view.isHidden = true
            
            let fromImageView = (photoBrower.collectionView.visibleCells.first as? MQPhotoCell)?.imageView
            
            imageView.image = fromImageView?.image
            imageView.frame = fromImageView?.convert(fromImageView?.bounds ?? .zero, to: window.transitionView) ?? .zero
            
            window.transitionView.addSubview(imageView)
            
        }.transition { [weak self] _ in
            
            guard let strongSelf = self else { return }
            
            let sourceView = photoBrower.sourceView
            
            imageView.frame = sourceView?.convert(sourceView?.frame ?? .zero, to: window.transitionView) ?? .zero
            
            strongSelf.window?.dimmingView.alpha = 0.0
            
        }.end { [weak self] isFinish in
            
            imageView.removeFromSuperview()
            
            photoBrower.view.isHidden = true
            
            self?.window = nil
            
            UIApplication.shared.keyWindow?.makeKeyAndVisible()
            
            completion(isFinish)
            
        }.perform()
    }
}

