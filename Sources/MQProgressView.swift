import UIKit

public class MQProgressView: UIView {
    
    public var progress: CGFloat = 0 {
        
        didSet{
            
            self.fixProgress()
            
            self.fanShapedLayer.path = self.makeProgressPath(progress: self.fixedProgress).cgPath
        }
    }
    
    private var fixedProgress: CGFloat = 0.0
    
    private func fixProgress() {
        if self.progress.isLess(than: 0) {
            self.fixedProgress = 0
        } else if self.progress.isLessThanOrEqualTo(1) {
            self.fixedProgress = self.progress
        } else {
            self.fixedProgress = 1
        }
    }
    
    public var strokeColor = UIColor(white: 1.0, alpha: 0.8)
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        let length = self.radius * 2
        
        self.frame.size = CGSize(width: length, height: length)
        
        self.backgroundColor = UIColor.clear
        
        self.setupLayers()
    }
    
    private let radius: CGFloat = 25
    
    private let circleLayer = CAShapeLayer()
    private let fanShapedLayer = CAShapeLayer()
    
    private func setupLayers() {
        
        self.circleLayer.strokeColor = self.strokeColor.cgColor
        self.circleLayer.fillColor = UIColor.clear.cgColor
        self.circleLayer.path = {
            let path = UIBezierPath(arcCenter: self.center, radius: radius - 1.0, startAngle: 0, endAngle: CGFloat.pi * 2.0, clockwise: true)
            return path.cgPath
        }()
        self.circleLayer.lineWidth = 2.0
        self.layer.addSublayer(self.circleLayer)
        
        self.fanShapedLayer.fillColor = self.strokeColor.cgColor
        self.layer.addSublayer(self.fanShapedLayer)
    }
    
    private func makeProgressPath(progress: CGFloat) -> UIBezierPath {
        
        let center = CGPoint(x: self.radius, y: self.radius)
        let radius = self.radius - 4.0
        
        let start = -CGFloat.pi / 2.0
        let end = -CGFloat.pi / 2.0 + CGFloat.pi * 2 * self.fixedProgress
        
        let path = UIBezierPath()
        path.move(to: center)
        path.addLine(to: CGPoint(x: center.x, y: center.y - radius))
        path.addArc(withCenter: center, radius: radius, startAngle: start, endAngle: end, clockwise: true)
        path.close()
        
        return path
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
