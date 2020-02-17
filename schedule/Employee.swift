import Foundation


final class Employee: Codable {
    final class Contacts: Codable {
        init(address: String? = nil,
             email: String? = nil,
             phone: String? = nil) {

            self.address = address
            self.email = email
            self.phone = phone
        }

        let address: String?
        let email: String?
        let phone: String?


    }
    
    init(id: Int, name: String,
         image: String? = nil,
         position: [String]? = nil,
         degree: String? = nil,
         rank: String? = nil,
         contacts: Contacts) {
        self.id = id
        self.name = name
        self.image = image
        self.position = position
        self.degree = degree
        self.rank = rank
        self.contacts = contacts
    }
    
    let id: Int
    let name: String
    let image: String?
    let position: [String]?
    let degree: String?
    let rank: String?
    let contacts: Contacts


}
