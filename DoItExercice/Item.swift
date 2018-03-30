import Foundation

class Item : Codable{
    var name: String
    var checked = false
    
    init(name: String) {
        self.name = name
    }
    
}
