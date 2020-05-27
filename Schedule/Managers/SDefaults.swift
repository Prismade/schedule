import Foundation

final class SDefaults {
    
    enum UserKind: String {
        case student = "student"
        case teacher = "teacher"
    }
    
    enum CacheUserKind: String {
        case student = "student"
        case teacher = "teacher"
        case both = "both"
    }
    
    enum FilePrefixKind {
        case student
        case teacher
        case building
        case employee
    }
    
    // MARK: - Static Properties
    
    static let defaultUserKey = "DefaultUser"
    static let studentIdKey = "StudentId"
    static let teacherIdKey = "TeacherId"
    static let isCachingEnabledKey = "IsCachingEnabled"
    static let cachingUserKindKey = "CachingUserKind"
    static let studentCacheFilePrefixKey = "StudentCacheFilePrefix"
    static let teacherCacheFilePrefixKey = "TeacherCacheFilePrefix"
    static let buildingCacheFilePrefixKey = "BuildingCacheFilePrefix"
    static let employeeCacheFilePrefixKey = "EmployeeCacheFilePrefix"
    
    static let defaults = UserDefaults.standard
    
    static var defaultUser: UserKind {
        set {
            defaults.set(newValue.rawValue, forKey: defaultUserKey)
        }
        
        get {
            let userKind = defaults.string(forKey: defaultUserKey)!
            return UserKind(rawValue: userKind)!
        }
    }
    
    static var studentId: Int? {
        set {
            defaults.set(newValue, forKey: studentIdKey)
        }
        
        get {
            return defaults.object(forKey: studentIdKey) as? Int
        }
    }
    
    static var teacherId: Int? {
        set {
            defaults.set(newValue, forKey: teacherIdKey)
        }
        
        get {
            return defaults.object(forKey: teacherIdKey) as? Int
        }
    }
    
    static var isCachingEnabled: Bool {
        set {
            defaults.set(newValue, forKey: isCachingEnabledKey)
        }
        
        get {
            return defaults.bool(forKey: isCachingEnabledKey)
        }
    }
    
    static var cachingUserKind: CacheUserKind {
        set {
            defaults.set(newValue.rawValue, forKey: cachingUserKindKey)
        }
        
        get {
            let userKind = defaults.string(forKey: cachingUserKindKey)!
            return CacheUserKind(rawValue: userKind)!
        }
    }
    
    // MARK: - Static Methods
    
    static func filePrefix(for prefixKind: FilePrefixKind) -> String {
        switch prefixKind {
            case .student:
                return defaults.string(forKey: studentCacheFilePrefixKey)!
            case .teacher:
                return defaults.string(forKey: teacherCacheFilePrefixKey)!
            case .building:
                return defaults.string(forKey: buildingCacheFilePrefixKey)!
            case .employee:
                return defaults.string(forKey: employeeCacheFilePrefixKey)!
        }
    }
    
    static func launchSetup() {
        if UserDefaults.standard.object(forKey: defaultUserKey) == nil {
            UserDefaults.standard.set("student", forKey: defaultUserKey)
        }
        
        if UserDefaults.standard.object(forKey: isCachingEnabledKey) == nil {
            UserDefaults.standard.set(false, forKey: isCachingEnabledKey)
        }
        
        if UserDefaults.standard.object(forKey: cachingUserKindKey) == nil {
            UserDefaults.standard.set("student", forKey: cachingUserKindKey)
        }
        
        //        if UserDefaults.standard.object(forKey: "RequestInterval") == nil {
        //            UserDefaults.standard.set(2, forKey: "RequestInterval")
        //        }
        
        if UserDefaults.standard.object(forKey: studentCacheFilePrefixKey) == nil {
            UserDefaults.standard.set("student", forKey: studentCacheFilePrefixKey)
        }
        
        if UserDefaults.standard.object(forKey: teacherCacheFilePrefixKey) == nil {
            UserDefaults.standard.set("teacher", forKey: teacherCacheFilePrefixKey)
        }
        
        if UserDefaults.standard.object(forKey: buildingCacheFilePrefixKey) == nil {
            UserDefaults.standard.set("buildings", forKey: buildingCacheFilePrefixKey)
        }
        
        if UserDefaults.standard.object(forKey: employeeCacheFilePrefixKey) == nil {
            UserDefaults.standard.set("employee", forKey: employeeCacheFilePrefixKey)
        }
    }
    
}
