import UIKit

class MQPhotoBrowerTransition {
    
    let duration: TimeInterval
    
    init(duration: TimeInterval = 0.3) {
        
        self.duration = duration
    }
    
    private var prepareBlock: ((Void) -> Void) = { _ in }
    
    private var transitionBlock: ((Void) -> Void) = { _ in }
    
    private var endBlock: ((Bool) -> Void) = { _ in }
    
    func prepare(_ block: @escaping (Void) -> Void) -> Self {
        
        self.prepareBlock = block
        
        return self
    }
    
    func transition(_ block: @escaping (Void) -> Void) -> Self {
        
        self.transitionBlock = block
        
        return self
    }
    
    func end(_ block: @escaping (Bool) -> Void) -> Self {
        
        self.endBlock = block
        
        return self
    }
    
    func perform() {
        
        self.prepareBlock()
        
        UIView.animate(withDuration: self.duration, animations: {
            
            self.transitionBlock()
            
        }, completion: { isComplete in
            
            self.endBlock(isComplete)
        })
    }
}
