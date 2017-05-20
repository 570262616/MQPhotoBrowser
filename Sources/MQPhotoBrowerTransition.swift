import UIKit

class MQPhotoBrowerTransition {
    
    fileprivate class MQPhotoBrowerWindow: UIWindow {
        
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
    
    fileprivate init() { self.window = nil }
    
    fileprivate var window: MQPhotoBrowerTransition.MQPhotoBrowerWindow?
    
    static let shared = MQPhotoBrowerTransition()
    
    func create(rootVC: UIViewController) {
        
        let screenSize = UIScreen.main.bounds.size
        
        let frame = CGRect(origin: .zero, size: CGSize(width: screenSize.width, height: screenSize.height + 1.0))
        
        let window = MQPhotoBrowerTransition.MQPhotoBrowerWindow(frame: frame)
        
        window.rootViewController = rootVC
        
        window.makeKeyAndVisible()
        
        self.window = window
    }
    
    func destroy() {
        
        self.window = nil
        
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }
    
    func updateDimmingViewAlpha(_ alpha: CGFloat) {
        
        self.window?.dimmingView.alpha = alpha
    }
}

protocol MQPhotoBrowerTransitionDelegate: class {
    
    func animatorForShow(dimmingView: UIView, transitionView: UIView) -> MQPhotoBrowerAnimator
    
    func animatorForDismiss(dimmingView: UIView, transitionView: UIView) -> MQPhotoBrowerAnimator
}

extension MQPhotoBrowerTransitionDelegate where Self: UIViewController {
    
    var transition: MQPhotoBrowerTransition {
        
        return MQPhotoBrowerTransition.shared
    }
    
    func show(completion: @escaping (Bool) -> Void) {
        
        let transition = self.transition
        
        transition.create(rootVC: self)
        
        guard let window = transition.window else { completion(false); return }
        
        self.animatorForShow(dimmingView: window.dimmingView, transitionView: window.transitionView).perform { isFinish in
            
            completion(isFinish)
        }
    }
    
    func dismiss(completion: @escaping (Bool) -> Void) {
        
        let transition = self.transition
        
        guard let window = transition.window else { completion(false); return }
        
        self.animatorForDismiss(dimmingView: window.dimmingView, transitionView: window.transitionView).perform { isFinish in
            
            completion(isFinish)
            
            transition.destroy()
        }
    }
}

