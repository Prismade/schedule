import Foundation
import Alamofire
import SwiftSoup

struct SEmMError: Error {
    enum ErrorKind {
        case requestFailure(AFError)
        case emptyResponse
        case stringCreationFailure
        case domManipulationFailure(Error)
        case cacheWriteError(SCMError)
    }
    
    let kind: ErrorKind
    var localizedDescription: String
}

final class SEmployeeManager {
    
    // MARK: - Static Properties
    
    static let shared = SEmployeeManager()
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    func requestData(for employeeId: Int, completion: @escaping (Result<SEmployee, SEmMError>) -> Void) {
        if let data = SCacheManager.shared.retrieveEmployee(id: employeeId) {
            completion(.success(data))
        } else {
            SApiManager.shared.getEmployeeData(for: employeeId) { response in
                switch response.result {
                case .success(let htmlData):
                    completion(self.parse(htmlData, for: employeeId))
                case .failure(let error):
                    completion(.failure(SEmMError(kind: .requestFailure(error), localizedDescription: "Request failed")))
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func parse(_ dataFromResponse: Data?, for employeeId: Int) -> Result<SEmployee, SEmMError> {
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
                    
                    let employee = SEmployee(
                        id: employeeId,
                        name: name,
                        image: image,
                        position: positions,
                        degree: degree,
                        rank: rank,
                        contacts: SEmployee.SContacts(
                            address: address,
                            email: email,
                            phone: phone))
                    
                    try SCacheManager.shared.cacheEmployee(id: employeeId, employee)
                    
                    return .success(employee)
                } catch let error where error is SCMError {
                    return .failure(SEmMError(kind: .cacheWriteError(error as! SCMError), localizedDescription: "Failed to write to cache"))
                } catch {
                    return .failure(SEmMError(kind: .domManipulationFailure(error), localizedDescription: "Failed to perform operation on DOM"))
                }
            } else {
                return .failure(SEmMError(kind: .stringCreationFailure, localizedDescription: "Failed to create string from data: got nil string"))
            }
        } else {
            return .failure(SEmMError(kind: .emptyResponse, localizedDescription: "Response data is nil"))
        }
    }
    
}
