import UIKit

class MQPhotoBrowerWindow: UIWindow {
    
    let dimmingView = UIView()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.dimmingView.frame = CGRect(origin: .zero, size: frame.size)
        
        self.dimmingView.backgroundColor = .black
        
        self.dimmingView.alpha = 1.0
        
        self.addSubview(self.dimmingView)
        
        self.backgroundColor = .clear
        
        self.windowLevel = UIWindowLevelStatusBar + 10000.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
