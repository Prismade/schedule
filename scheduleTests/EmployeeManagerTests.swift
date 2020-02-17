import XCTest
@testable import Расписание


class EmployeeManagerTests: XCTestCase {

    func testCompleteProfileParsing() {
        
        let expectation = XCTestExpectation(description: "Test complete profile parsing")
        
        EmployeeManager.shared.data(for: 159) { result in
            switch result {
            case .success(let employee):
                print(employee.name)
                print(employee.image ?? "nil image")
                print(employee.degree ?? "nil degree")
                print(employee.rank ?? "nil rank")
                for p in employee.position {
                    print(p)
                }
                print(employee.contacts.address ?? "nil address")
                print(employee.contacts.phone ?? "nil phone")
                print(employee.contacts.email ?? "nil email")
                
                expectation.fulfill()
                
            case .failure(let error):
                switch error.kind {
                case .domManipulationFailure(let domError):
                    print("DOM manipulation error: \(domError.localizedDescription)")
                case .emptyResponse:
                    print(error.localizedDescription)
                case .requestFailure(let afError):
                    print("Request failed: \(afError.localizedDescription)")
                case .stringCreationFailure:
                    print(error.localizedDescription)
                case .cacheWriteError(let cmError):
                    print(cmError.localizedDescription)
                }
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testIncompleteProfileParsing() {
        
        let expectation = XCTestExpectation(description: "Test incomplete profile parsing")
        
        EmployeeManager.shared.data(for: 6532) { result in
            switch result {
            case .success(let employee):
                print(employee.name)
                print(employee.image ?? "nil image")
                print(employee.degree ?? "nil degree")
                print(employee.rank ?? "nil rank")
                for p in employee.position {
                    print(p)
                }
                print(employee.contacts.address ?? "nil address")
                print(employee.contacts.phone ?? "nil phone")
                print(employee.contacts.email ?? "nil email")
                
                expectation.fulfill()
                
            case .failure(let error):
                switch error.kind {
                case .domManipulationFailure(let domError):
                    print("DOM manipulation error: \(domError.localizedDescription)")
                case .emptyResponse:
                    print(error.localizedDescription)
                case .requestFailure(let afError):
                    print("Request failed: \(afError.localizedDescription)")
                case .stringCreationFailure:
                    print(error.localizedDescription)
                case .cacheWriteError(let cmError):
                    print(cmError.localizedDescription)
                }
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }


}
