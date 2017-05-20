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
            
            self.windowLevel = UIWindowLevelStatusBar + 1.0
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    private init() { self.window = nil }
    
    private var window: MQPhotoBrowerWindowManager.MQPhotoBrowerWindow?
    
    static let shared = MQPhotoBrowerWindowManager()
    
    private func makeFullScreenWindow() -> MQPhotoBrowerWindow {
        
        let screenSize = UIScreen.main.bounds.size
        
        let frame = CGRect(origin: .zero, size: CGSize(width: screenSize.width, height: screenSize.height + 1.0))
        
        return MQPhotoBrowerWindowManager.MQPhotoBrowerWindow(frame: frame)
    }
    
    func updateDimmingViewAlpha(_ alpha: CGFloat) {
        
        self.window?.dimmingView.alpha = alpha
    }
    
    func show(withRootViewController viewController: UIViewController) {
        
        let window = self.makeFullScreenWindow()
        
        window.rootViewController = viewController
        
        window.makeKeyAndVisible()
        
        self.window = window
    }
    
    func dismiss() {
        
        self.window = nil
        
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }
}

