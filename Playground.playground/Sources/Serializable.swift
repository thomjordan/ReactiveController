
import Foundation

public protocol Serializable : Encodable {
    
    func serialize() -> Data?
}


public extension Serializable {
    
    public func serialize() -> Data? {
        
        let encoder = PropertyListEncoder()
        
        return try? encoder.encode(self)
    }
}
 
