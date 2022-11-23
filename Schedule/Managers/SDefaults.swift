import Foundation

final class SDefaults {
    enum FilePrefixKind {
        case student
        case building
        case employee
    }
    
    // MARK: - Static Properties
    
    static let studentIdKey = "StudentId"
    static let studentCacheFilePrefixKey = "StudentCacheFilePrefix"
    static let buildingCacheFilePrefixKey = "BuildingCacheFilePrefix"
    static let employeeCacheFilePrefixKey = "EmployeeCacheFilePrefix"
    static let studentNameKey = "StudentName"
    
    static let defaults = UserDefaults.standard
    
    static var studentId: Int? {
        set {
            defaults.set(newValue, forKey: studentIdKey)
        }
        
        get {
            return defaults.object(forKey: studentIdKey) as? Int
        }
    }
    
    static var studentName: String? {
        set {
            defaults.set(newValue, forKey: studentNameKey)
        }
        
        get {
            return defaults.string(forKey: studentNameKey)
        }
    }
    
    // MARK: - Static Methods
    
    static func filePrefix(for prefixKind: FilePrefixKind) -> String {
        switch prefixKind {
            case .student:
                return defaults.string(forKey: studentCacheFilePrefixKey)!
            case .building:
                return defaults.string(forKey: buildingCacheFilePrefixKey)!
            case .employee:
                return defaults.string(forKey: employeeCacheFilePrefixKey)!
        }
    }
    
    static func launchSetup() {
        if UserDefaults.standard.object(forKey: studentCacheFilePrefixKey) == nil {
            UserDefaults.standard.set("student", forKey: studentCacheFilePrefixKey)
        }
        
        if UserDefaults.standard.object(forKey: buildingCacheFilePrefixKey) == nil {
            UserDefaults.standard.set("buildings", forKey: buildingCacheFilePrefixKey)
        }
        
        if UserDefaults.standard.object(forKey: employeeCacheFilePrefixKey) == nil {
            UserDefaults.standard.set("employee", forKey: employeeCacheFilePrefixKey)
        }
    }
    
}
