import UIKit

class MQPhotoBrowerWindowManager {
    
    private class MQPhotoBrowerWindow: UIWindow {
        
        let dimmingView = UIView()
        
        override init(frame: CGRect) {
            
            super.init(frame: frame)
            
            self.dimmingView.frame = CGRect(origin: .zero, size: frame.size)
            
            self.dimmingView.backgroundColor = .black
            
            self.dimmingView.alpha = 1.0
            
            self.addSubview(self.dimmingView)
            
            self.backgroundColor = .clear
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    private init() { self.photoBrowerWindow = nil }
    
    private var photoBrowerWindow: MQPhotoBrowerWindowManager.MQPhotoBrowerWindow?
    
    static let shared = MQPhotoBrowerWindowManager()
    
    var dimmingViewAlpha: CGFloat {
        get {
            return self.photoBrowerWindow?.dimmingView.alpha ?? 0
        }
        set {
            self.photoBrowerWindow?.dimmingView.alpha = newValue
        }
    }
    
    func show(withRootViewController viewController: UIViewController) {
        
        let window = MQPhotoBrowerWindowManager.MQPhotoBrowerWindow(frame: UIScreen.main.bounds)
        
        window.rootViewController = viewController
        
        window.makeKeyAndVisible()
        
        self.photoBrowerWindow = window
    }
    
    func dismiss() {
        
        self.photoBrowerWindow = nil
        
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }
}

