import XCTest
@testable import Расписание


class EmployeeManagerTests: XCTestCase {

    func testParsing() {
        
        let expectation = XCTestExpectation(description: "Test em parsing")
        
        EmployeeManager.shared.data(for: 159) { result in
            switch result {
            case .success(let employee):
                print(employee.name)
                print(employee.image ?? "nil image")
                expectation.fulfill()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }


}
