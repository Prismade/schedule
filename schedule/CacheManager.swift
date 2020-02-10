import Foundation


struct CMError: Error {
    enum ErrorKind {
        case fileWriteError
        case fileDeletionError
    }
    
    let kind: ErrorKind
    var localizedDescription: String
}


final class CacheManager {
    
    static let shared = CacheManager()
    
    private init() {}
    
    private let fileManager = FileManager.default
    
    func cache(_ data: [ScheduleDay], weekOffset: Int, to fileName: String) throws {
        do {
            if let url = getFileUrl(for: "\(fileName)\(UserDefaults.standard.integer(forKey: "UserId"))\(weekOffset)") {
                let jsonData = try JSONEncoder().encode(CacheItem(data: data, expirationTime: TimeManager.shared.getMonday(for: 1)))
                try jsonData.write(to: url, options: .atomic)
            }
        } catch let error {
            throw CMError(kind: .fileWriteError, localizedDescription: error.localizedDescription)
        }
    }
    
    func retrieve(weekOffset: Int, from fileName: String) -> [ScheduleDay]? {
        let path = "\(fileName)\(UserDefaults.standard.integer(forKey: "UserId"))\(weekOffset)"
        
        if let url = getFileUrl(for: path) {
            if fileManager.fileExists(atPath: url.path) {
                do {
                    let jsonData = try Data(contentsOf: url)
                    let cacheItem = try JSONDecoder().decode(CacheItem.self, from: jsonData)
                    if TimeManager.shared.validateCache(expirationTime: cacheItem.expirationTime) {
                        return cacheItem.data
                    }
                } catch {
                    return nil
                }
            }
        }
        
        return nil
    }
    
    func clear(fileNamePrefixes: [String]) throws {
        if let directory = getRootUrl() {
            do {
                let files = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.nameKey])
                for file in files {
                    for fileNamePrefix in fileNamePrefixes {
                        if file.lastPathComponent.hasPrefix(fileNamePrefix) {
                            try fileManager.removeItem(at: file)
                        }
                    }
                }
            } catch let error {
                throw CMError(kind: .fileDeletionError, localizedDescription: error.localizedDescription)
            }
        }
    }
    
    private func getFileUrl(for fileName: String) -> URL? {
        if let url = getRootUrl() {
            do {
                if !fileManager.fileExists(atPath: url.path) {
                    try fileManager.createDirectory(at: url, withIntermediateDirectories: false)
                }
            } catch {
                return nil
            }
            return url.appendingPathComponent(fileName, isDirectory: false)
        } else {
            return nil
        }
    }
    
    private func getRootUrl() -> URL? {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        return urls.first
    }


}
