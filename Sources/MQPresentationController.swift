import UIKit

private struct Tag {
    static let dimmingView = 10000
}

class MQPresentationController: UIPresentationController {
    
    var dimmingView: UIView? {
        return self.containerView?.viewWithTag(Tag.dimmingView)
    }
    
    override func presentationTransitionWillBegin() {
        
        guard let containerView = self.containerView else { return }
        
        let dimmingView: UIView = {
            
            let view = UIView(frame: containerView.bounds)
            
            view.tag = Tag.dimmingView
            view.backgroundColor = .black
            view.isOpaque = false
            
            return view
        }()
        
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(dimmingView)
        
        let transitionCoordinator = self.presentingViewController.transitionCoordinator
        
        dimmingView.alpha = 0.0
        
        transitionCoordinator?.animate(alongsideTransition: { context in
            
            dimmingView.alpha = 1.0
            
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        
        let transitionCoordinator = self.presentingViewController.transitionCoordinator
        
        transitionCoordinator?.animate(alongsideTransition: { context in
            
            self.dimmingView?.alpha = 0.0
            
        }, completion: nil)
        
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        
        if container === self.presentedViewController {
            
            self.containerView?.setNeedsLayout()
        }
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        
        if container === self.presentedViewController {
            
            return container.preferredContentSize
        } else {
            
            return super.size(forChildContentContainer: container, withParentContainerSize: parentSize)
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        
        return self.containerView?.bounds ?? .zero
    }
    
    override func containerViewWillLayoutSubviews() {
        
        super.containerViewWillLayoutSubviews()
        
        let containerView = self.containerView
        
        self.dimmingView?.frame = containerView?.bounds ?? .zero
        
        self.presentedView?.frame = self.frameOfPresentedViewInContainerView
    }
}
