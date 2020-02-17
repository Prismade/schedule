import Foundation


final class Employee: Codable {
    final class Contacts: Codable {
        let address: String?
        let email: String?
        let phone: String?
    }
    
    let id: Int
    let name: String
    let image: String?
    let position: [String]?
    let degree: String?
    let rank: String?
    let contacts: Contacts
}
