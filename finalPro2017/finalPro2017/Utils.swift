
import Foundation

extension String{
    mutating func removeDot()
    {while self.contains(".") {
        self.remove(at: self.characters.index(of: ".")!)
        }
    }
    
}
