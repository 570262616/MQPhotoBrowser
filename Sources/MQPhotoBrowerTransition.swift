import UIKit

extension MQPhotoBrowerViewController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return self.makePresentAnimator()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return self.makeDismissAnimator()
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return MQPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    private func makePresentAnimator() -> MQBaseTransitionAnimator {
        
        let sourceView = self.sourceView
        
        let scaleImageView = UIImageView()
        
        return MQBaseTransitionAnimator().prepare({ container, from, to in
            
            from?.asStart()
            to?.asEnd()
            
            scaleImageView.contentMode = .scaleAspectFill
            scaleImageView.image = sourceView?.image
            scaleImageView.clipsToBounds = true
            scaleImageView.frame = sourceView?.convert(sourceView?.frame ?? .zero, to: container) ?? .zero
            
            container.addSubview(scaleImageView)
            
        }).initial({ container, from, to in
            
            to?.view?.isHidden = true
            
        }).transition({ container, from, to in
            
            guard let size = scaleImageView.image?.size, !size.width.isLessThanOrEqualTo(0.0) else { return }
            
            let bounds = to?.view?.bounds ?? .zero
            
            let height = bounds.width * size.height / size.width
            
            scaleImageView.bounds = CGRect(x: 0, y: 0, width: bounds.width, height: height)
            
            scaleImageView.center = to?.view?.center ?? .zero
            
        }).end({ container, from, to in
            
            from?.asEnd()
            to?.asEnd()
            
            to?.view?.isHidden = false
            
            scaleImageView.removeFromSuperview()
        })
    }
    
    private func makeDismissAnimator() -> MQBaseTransitionAnimator {
        
        let sourceView = (self.collectionView.visibleCells.first as? MQPhotoCell)?.imageView
        
        let destinationView = self.sourceView
        
        let scaleImageView = UIImageView()
        
        return MQBaseTransitionAnimator().prepare({ container, from, to in
            
            from?.asStart()
            to?.asStart()
            
            scaleImageView.contentMode = .scaleAspectFill
            scaleImageView.image = sourceView?.image
            scaleImageView.clipsToBounds = true
            scaleImageView.frame = sourceView?.convert(sourceView?.bounds ?? .zero, to: container) ?? .zero
            
            container.addSubview(scaleImageView)
            
        }).initial({ container, from, to in
            
            from?.view?.isHidden = true
            
        }).transition({ container, from, to in
            
            scaleImageView.frame = destinationView?.convert(destinationView?.frame ?? .zero, to: container) ?? .zero
            
        }).end({ container, from, to in
            
            from?.asEnd()
            to?.asEnd()
            
            from?.view?.isHidden = false
            
            scaleImageView.removeFromSuperview()
        })
    }
}

