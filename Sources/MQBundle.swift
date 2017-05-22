import Foundation

class MQBundle: Bundle {
    
    class override var main: Bundle { return bundle }
}

fileprivate let bundle: Bundle = {
    
    guard
        let bundleURL = Bundle(for: MQBundle.self).url(forResource: "MQPhotoBrowser", withExtension: "bundle"),
        let bundle = Bundle(url: bundleURL) else {
            
            fatalError("Load MQPhotoBrowser's bundle failed.")
    }
    
    return bundle
}()
