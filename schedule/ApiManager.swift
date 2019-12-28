import Foundation
import Alamofire

/**
 Методы для запросов к API
 */
protocol ApiManaging {
    /**
     Получение списка институтов для студентов.
     - parameter completion: Замыкание, выполняющееся по завершении запроса. В качестве параметра передается результат запроса.
     - returns: Объект запроса (для отладки). Можно опустить получение.
     */
    @discardableResult
    func getStudentDivisions(completion: @escaping (DataResponse<[Division], AFError>) -> Void) -> Request

    /**
     Получение списка институтов для преподавателей.
     - parameter completion: Замыкание, выполняющееся по завершении запроса. В качестве параметра передается результат запроса.
     - returns: Объект запроса (для отладки). Можно опустить получение.
     */
    @discardableResult
    func getTeacherDivisions(completion: @escaping (DataResponse<[Division], AFError>) -> Void) -> Request

    /**
     Получение списка курсов.
     - parameter division: id института.
     - parameter completion: Замыкание, выполняющееся по завершении запроса. В качестве параметра передается результат запроса.
     - returns: Объект запроса (для отладки). Можно опустить получение.
     */
    @discardableResult
    func getCourses(for division: Int, completion: @escaping (DataResponse<[Course], AFError>) -> Void) -> Request

    /**
     Получение списка кафедр для преподавателей.
     - parameter division: id института.
     - parameter completion: Замыкание, выполняющееся по завершении запроса. В качестве параметра передается результат запроса.
     - returns: Объект запроса (для отладки). Можно опустить получение.
     */
    @discardableResult
    func getDepartments(for division: Int, completion: @escaping (DataResponse<[Department], AFError>) -> Void) -> Request

    /**
     Получение списка групп для студентов.
     - parameter course: номер курса.
     - parameter division: id института.
     - parameter completion: Замыкание, выполняющееся по завершении запроса. В качестве параметра передается результат запроса.
     - returns: Объект запроса (для отладки). Можно опустить получение.
     */
    @discardableResult
    func getGroups(for course: Int, at division: Int, completion: @escaping (DataResponse<[Group], AFError>) -> Void) -> Request

    /**
     Получение списка преподавателей.
     - parameter department: id кафедры.
     - parameter division: id института.
     - parameter completion: Замыкание, выполняющееся по завершении запроса. В качестве параметра передается результат запроса.
     - returns: Объект запроса (для отладки). Можно опустить получение.
     */
    @discardableResult
    func getTeachers(for department: Int, at division: Int, completion: @escaping (DataResponse<[Teacher], AFError>) -> Void) -> Request

    /**
     Получение расписания для студентов.
     - parameter group: id группы.
     - parameter weekOffset: сдвиг (в неделях) относительно текущей недели.
     - parameter completion: Замыкание, выполняющееся по завершении запроса. В качестве параметра передается результат запроса.
     - returns: Объект запроса (для отладки). Можно опустить получение.
     */
    @discardableResult
    func getStudentSchedule(for group: Int, on weekOffset: Int, completion: @escaping (DataResponse<[Lesson], AFError>) -> Void) -> Request

    /**
     Получение расписания для преподавателей.
     - parameter teacher: id преподавателя.
     - parameter weekOffset: сдвиг (в неделях) относительно текущей недели.
     - parameter completion: Замыкание, выполняющееся по завершении запроса. В качестве параметра передается результат запроса.
     - returns: Объект запроса (для отладки). Можно опустить получение.
     */
    @discardableResult
    func getTeacherSchedule(for teacher: Int, on weekOffset: Int, completion: @escaping (DataResponse<[Lesson], AFError>) -> Void) -> Request
    
    /**
     Получение расписания экзаменов на текущий семестр (если оно есть)
     - parameter group: id группы
     - returns: Объект запроса (для отладки). Можно опустить получение.
     */
    @discardableResult
    func getExamsSchedule(for group: Int, completion: @escaping (DataResponse<[Exam], AFError>) -> Void) -> Request

}


final class ApiManager: ApiManaging {

    // MARK: - Static Properties

    static let shared = ApiManager()

    // MARK: - Private Properties

    private let session = Alamofire.Session()
    private let baseUrl = "http://oreluniver.ru/schedule"

    // MARK: - Initializers

    private init() {}

    // MARK: - Public Methods

    @discardableResult
    func getStudentDivisions(completion: @escaping (DataResponse<[Division], AFError>) -> Void) -> Request {
        let url = baseUrl + "/divisionlistforstuds"
        return session.request(url).responseDecodable(completionHandler: completion)
    }
    
    @discardableResult
    func getTeacherDivisions(completion: @escaping (DataResponse<[Division], AFError>) -> Void) -> Request {
        let url = baseUrl + "/divisionlistforpreps"
        return session.request(url).responseDecodable(completionHandler: completion)
    }

    @discardableResult
    func getCourses(for division: Int, completion: @escaping (DataResponse<[Course], AFError>) -> Void) -> Request  {
        let url = baseUrl + "/\(division)/kurslist"
        return session.request(url).responseDecodable(completionHandler: completion)
    }

    @discardableResult
    func getDepartments(for division: Int, completion: @escaping (DataResponse<[Department], AFError>) -> Void) -> Request {
        let url = baseUrl + ""
        return session.request(url).responseDecodable(completionHandler: completion)
    }

    @discardableResult
    func getGroups(for course: Int, at division: Int, completion: @escaping (DataResponse<[Group], AFError>) -> Void) -> Request  {
        let url = baseUrl + "/\(division)/\(course)/grouplist"
        return session.request(url).responseDecodable(completionHandler: completion)
    }

    @discardableResult
    func getTeachers(for department: Int, at division: Int, completion: @escaping (DataResponse<[Teacher], AFError>) -> Void) -> Request {
        let url = baseUrl + ""
        return session.request(url).responseDecodable(completionHandler: completion)
    }

    @discardableResult
    func getStudentSchedule(for group: Int, on weekOffset: Int, completion: @escaping (DataResponse<[Lesson], AFError>) -> Void) -> Request  {
        let timeStamp: String = TimeManager.shared.getApiTimeKey(for: weekOffset)
        let url = baseUrl + "//\(group)///\(timeStamp)/printschedule"
        return session.request(url).responseDecodable(completionHandler: completion)
    }

    @discardableResult
    func getTeacherSchedule(for teacher: Int, on weekOffset: Int, completion: @escaping (DataResponse<[Lesson], AFError>) -> Void) -> Request  {
        let timeStamp: String = TimeManager.shared.getApiTimeKey(for: weekOffset)
        let url = baseUrl + "/\(teacher)////\(timeStamp)/printschedule"
        return session.request(url).responseDecodable(completionHandler: completion)
    }
    
    @discardableResult
    func getExamsSchedule(for group: Int, completion: @escaping (DataResponse<[Exam], AFError>) -> Void) -> Request {
        let url = baseUrl + "/\(group)////printexamschedule"
        return session.request(url).responseDecodable(completionHandler: completion)
    }


}
