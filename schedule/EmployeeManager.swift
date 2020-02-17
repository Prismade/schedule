import Foundation
import Alamofire
import SwiftSoup


struct EmMError: Error {
    enum ErrorKind {
        case requestFailure(AFError)
        case emptyResponse
        case stringCreationFailure
        case domManipulationFailure(Error)
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
                    var picture = ""
                    
                    let document = try SwiftSoup.parse(htmlString)
                    var element = try document.select("h1.center").first()!
                    name = try element.text()
                    
                    element = try document.select("img.img-circle").first()!
                    picture = try element.attr("src")
                    
                    let employee = Employee(id: employeeId, name: name, image: picture, contacts: Employee.Contacts())
                    return .success(employee)
                } catch let error {
                    return .failure(EmMError(kind: .domManipulationFailure(error), localizedDescription: "Failed to perform operation on DOM"))
                }
            } else {
                return .failure(EmMError(kind: .stringCreationFailure, localizedDescription: "Failed to create string from data. Got nil."))
            }
        } else {
            return .failure(EmMError(kind: .emptyResponse, localizedDescription: "Response data is nil"))
        }
    }
}
