import Foundation
import Alamofire
import SwiftSoup


struct EmMError: Error {
    enum ErrorKind {
        case requestFailure(AFError)
        case emptyResponse
        case stringCreationFailure
        case domManipulationFailure(Error)
        case cacheWriteError(CMError)
    }
    
    let kind: ErrorKind
    var localizedDescription: String
}


final class EmployeeManager {
    
    static let shared = EmployeeManager()
    
    private init() {}
    
    func data(for employeeId: Int, completion: @escaping (Result<Employee, EmMError>) -> Void) {
        if let data = CacheManager.shared.retrieveEmployee(id: employeeId) {
            completion(.success(data))
        } else {
            ApiManager.shared.getEmployeeData(for: employeeId) { response in
                switch response.result {
                case .success(let htmlData):
                    completion(self.parse(htmlData, for: employeeId))
                case .failure(let error):
                    completion(.failure(EmMError(kind: .requestFailure(error), localizedDescription: "Request failed")))
                }
            }
        }
    }
    
    private func parse(_ dataFromResponse: Data?, for employeeId: Int) -> Result<Employee, EmMError> {
        if let rawData = dataFromResponse {
            if let htmlString = String(data: rawData, encoding: .windowsCP1251) {
                do {
                    var name = ""
                    var image: String? = nil
                    var positions = [String]()
                    var degree: String? = nil
                    var rank: String? = nil
                    var address: String? = nil
                    var phone: String? = nil
                    var email: String? = nil
                    
                    let document = try SwiftSoup.parse(htmlString)
                    
                    let nameElement = try document.select("h1.center").first()!
                    name = try nameElement.text()
                    
                    let imgElement = try document.select("img.img-circle").first()!
                    let imgString = try imgElement.attr("src")
                    if imgString != "/img/employee/no_picture.png" {
                        image = imgString
                    }
                    
                    let positionElements = try document.select("p.profile-value[itemprop=post]")
                    for positionElement in positionElements.array() {
                        let position = try positionElement.text()
                        positions.append(position)
                    }
                    
                    if let degreeElement = try document.select("p.profile-value[itemprop=degree]").first() {
                        degree = try degreeElement.text()
                    }
                    
                    if let rankElement = try document.select("p.profile-value[itemprop=academStat]").first() {
                        rank = try rankElement.text()
                    }
                    
                    let contactsElements = try document.select("#contacts > p")
                    
                    let addressElement = try contactsElements.array()[0].getElementsByTag("span").first()!
                    let addressElementText = try addressElement.text()
                    if addressElementText != "" {
                        address = addressElementText
                    }
                    
                    let phoneElement = try contactsElements.array()[1].getElementsByTag("span").first()!
                    let phoneElementText = try phoneElement.text()
                    if phoneElementText != "" {
                        phone = phoneElementText
                    }
                    
                    let emailElement = try contactsElements.array()[2].getElementsByTag("span").first()!
                    let emailElementText = try emailElement.text()
                    if emailElementText != "" {
                        email = emailElementText
                    }
                    
                    let employee = Employee(
                        id: employeeId,
                        name: name,
                        image: image,
                        position: positions,
                        degree: degree,
                        rank: rank,
                        contacts: Employee.Contacts(
                            address: address,
                            email: email,
                            phone: phone))
                    
                    try CacheManager.shared.cacheEmployee(id: employeeId, employee)
                    
                    return .success(employee)
                } catch let error where error is CMError {
                    return .failure(EmMError(kind: .cacheWriteError(error as! CMError), localizedDescription: "Failed to write to cache"))
                } catch {
                    return .failure(EmMError(kind: .domManipulationFailure(error), localizedDescription: "Failed to perform operation on DOM"))
                }
            } else {
                return .failure(EmMError(kind: .stringCreationFailure, localizedDescription: "Failed to create string from data: got nil string"))
            }
        } else {
            return .failure(EmMError(kind: .emptyResponse, localizedDescription: "Response data is nil"))
        }
    }
}
