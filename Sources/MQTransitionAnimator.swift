import UIKit

public struct MQTransitionComponent {
    
    public let controller: UIViewController
    public let view: UIView?
    
    public let initialFrame: CGRect
    public let finalFrame: CGRect
    
    public func asStart() {
        self.view?.frame = self.initialFrame
    }
    
    public func asEnd() {
        self.view?.frame = self.finalFrame
    }
    
    public var reversed: MQTransitionComponent {
        return MQTransitionComponent(controller: self.controller, view: self.view, initialFrame: self.finalFrame, finalFrame: self.initialFrame)
    }
}

enum TransitionKey {
    
    case from
    case to
    
    public var viewControllerKey: UITransitionContextViewControllerKey {
        switch self {
        case .from:
            return .from
        case .to:
            return .to
        }
    }
    
    public var viewKey: UITransitionContextViewKey {
        switch self {
        case .from:
            return .from
        case .to:
            return .to
        }
    }
}

extension MQTransitionComponent {
    
    init?(context: UIViewControllerContextTransitioning, key: TransitionKey) {
        
        guard
            let vc = context.viewController(forKey: key.viewControllerKey) else {
                return nil
        }
        
        let v = context.view(forKey: key.viewKey)
        
        self.init(controller: vc, view: v, initialFrame: context.initialFrame(for: vc), finalFrame: context.finalFrame(for: vc))
    }
}

typealias TransitionInfo = (containerView: UIView, fromComponent: MQTransitionComponent?, toComponent: MQTransitionComponent?)

typealias TransitionHanler = (TransitionInfo) -> Swift.Void

extension MQAbstractTransitionAnimator: NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        
        let reval = type(of: self).init(duration: self.duration)
        
        reval.prepareHandler = self.prepareHandler
        reval.initialHandler = self.initialHandler
        reval.transitionHandler = self.transitionHandler
        reval.endHandler = self.endHandler
        
        return reval
    }
    
    var reversed: MQAbstractTransitionAnimator {
        
        guard let copy = self.copy() as? MQAbstractTransitionAnimator else { fatalError("Copy failed.") }
        
        copy.initialHandler = { container, from, to in
            self.transitionHandler((container, to?.reversed, from?.reversed))
        }
        
        copy.transitionHandler = { container, from, to in
            self.initialHandler((container, to?.reversed, from?.reversed))
        }
        
        return copy
    }
}

class MQAbstractTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration: TimeInterval
    
    required init(duration: TimeInterval = 0.35) {
        self.duration = duration
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    static let defaultPrepareHandler: TransitionHanler = { _ in
    }
    
    static let defaultInitialHandler: TransitionHanler = { _, _, to in
        to?.asStart()
    }
    
    static let defaultTransitionHandler: TransitionHanler = { _, _, to in
        to?.asEnd()
    }
    
    static let defaultEndHandler: TransitionHanler = { _, _, to in
        to?.asEnd()
    }
    
    fileprivate var prepareHandler      = MQAbstractTransitionAnimator.defaultPrepareHandler
    fileprivate var initialHandler      = MQAbstractTransitionAnimator.defaultInitialHandler
    fileprivate var transitionHandler   = MQAbstractTransitionAnimator.defaultTransitionHandler
    fileprivate var endHandler          = MQAbstractTransitionAnimator.defaultEndHandler
    
    func prepare(_ handler: @escaping TransitionHanler) -> Self {
        self.prepareHandler = handler
        return self
    }
    
    func initial(_ handler: @escaping TransitionHanler) -> Self {
        self.initialHandler = handler
        return self
    }
    
    func transition(_ handler: @escaping TransitionHanler) -> Self {
        self.transitionHandler = handler
        return self
    }
    
    func end(_ handler: @escaping TransitionHanler) -> Self {
        self.endHandler = handler
        return self
    }
    
    func makeTransitionInfo(using context: UIViewControllerContextTransitioning) -> TransitionInfo {
        
        let containerView = context.containerView
        
        let from = MQTransitionComponent(context: context, key: .from)
        let to = MQTransitionComponent(context: context, key: .to)
        
        if let toView = to?.view, toView.superview != containerView {
            containerView.addSubview(toView)
        }
        
        let info = (containerView, from, to)
        
        self.prepareHandler(info)
        
        self.initialHandler(info)
        
        return info
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let info = self.makeTransitionInfo(using: transitionContext)
        
        self.animating(with: info, animation: {
            
            self.transitionHandler(info)
            
        }) { finish in
            
            let wasCancled = transitionContext.transitionWasCancelled
            
            if wasCancled && info.toComponent?.view == info.containerView {
                info.toComponent?.view?.removeFromSuperview()
            }
            
            self.endHandler(info)
            
            transitionContext.completeTransition(!wasCancled)
        }
    }
    
    func animating(with info: TransitionInfo, animation: @escaping () -> Void, completion: @escaping (Bool) -> Void) {
        
        fatalError("Not implemented.")
    }
}

class MQBaseTransitionAnimator: MQAbstractTransitionAnimator {
    
    override func animating(with info: TransitionInfo, animation: @escaping () -> Void, completion: @escaping (Bool) -> Void) {
        
        UIView.animate(withDuration: self.duration, delay: 0.0, options: .curveEaseInOut, animations: animation, completion: completion)
    }
}
