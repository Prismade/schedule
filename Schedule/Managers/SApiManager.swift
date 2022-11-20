import Alamofire
import Foundation

final class SApiManager {
    
    // MARK: - Static Properties
    
    static let shared = SApiManager()
    
    // MARK: - Private Properties
    
    private let session = Alamofire.Session()
    private let baseUrl = "https://oreluniver.ru/schedule"
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Public Methods
    
    @discardableResult
    func getStudentDivisions(completion: @escaping (DataResponse<[SDivision], AFError>) -> Void) -> Request {
        let url = baseUrl + "/divisionlistforstuds"
        return session.request(url).responseDecodable(completionHandler: completion)
    }
    
    @discardableResult
    func getCourses(for division: Int, completion: @escaping (DataResponse<[SCourse], AFError>) -> Void) -> Request  {
        let url = baseUrl + "/\(division)/kurslist"
        return session.request(url).responseDecodable(completionHandler: completion)
    }
    
    @discardableResult
    func getGroups(for course: Int, at division: Int,
                   completion: @escaping (DataResponse<[SGroup], AFError>) -> Void) -> Request  {
        let url = baseUrl + "/\(division)/\(course)/grouplist"
        return session.request(url).responseDecodable(completionHandler: completion)
    }
    
    @discardableResult
    func getStudentSchedule(for group: Int, on weekOffset: Int, completion: @escaping (DataResponse<Data, AFError>) -> Void) -> Request  {
        let timeStamp: String = STimeManager.shared.getApiKey(for: weekOffset)
        let url = baseUrl + "//\(group)///\(timeStamp)/printschedule"
        return session.request(url).responseData(completionHandler: completion)
    }
    
    @discardableResult
    func getStudentExamsSchedule(for group: Int, completion: @escaping (DataResponse<[SExam], AFError>) -> Void) -> Request {
        let url = baseUrl + "/\(group)////printexamschedule"
        return session.request(url).responseDecodable(completionHandler: completion)
    }
    
    @discardableResult
    func getBuildingsData(completion: @escaping (DataResponse<SBuildingData, AFError>) -> Void) -> Request {
        let url = "https://oreluniver.ru/assets/js/buildings.json"
        return session.request(url).responseDecodable(completionHandler: completion)
    }
    
    @discardableResult
    func getEmployeeData(for id: Int, completion: @escaping (DataResponse<Data?, AFError>) -> Void) -> Request {
        let url = "https://oreluniver.ru/employee/\(id)"
        return session.request(url).response(completionHandler: completion)
    }
    
}
