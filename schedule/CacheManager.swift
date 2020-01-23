import Foundation


enum CMError: Error {
    case fileWriteError
}


final class CacheManager {
    
    static let shared = CacheManager()
    
    private init() {}
    
    private let fileManager = FileManager.default
    
    func cache(_ data: [ScheduleViewModel.Day], weekOffset: Int, to fileName: String) throws {
        if weekOffset == 0 {
            do {
                if let url = getFileUrl(for: fileName) {
                    let jsonData = try JSONEncoder().encode(data)
                    try jsonData.write(to: url, options: .atomic)
                }
            } catch {
                throw CMError.fileWriteError
            }
        } else if weekOffset > 0 {
            do {
                if let url = getFileUrl(for: "\(fileName)\(weekOffset)") {
                    let jsonData = try JSONEncoder().encode(CacheItem(data: data, expirationTime: TimeManager.shared.getMonday(for: weekOffset)))
                    try jsonData.write(to: url, options: .atomic)
                }
            } catch {
                throw CMError.fileWriteError
            }
        } else {
            return
        }
    }
    
    func retrieve(weekOffset: Int, from fileName: String) -> [ScheduleViewModel.Day]? {
        let path: String
        if weekOffset == 0 {
            path = fileName
        } else if weekOffset > 0 {
            path = "\(fileName)\(weekOffset)"
        } else {
            return nil
        }

        if let url = getFileUrl(for: path) {
            if fileManager.fileExists(atPath: url.path) {
                do {
                    let jsonData = try Data(contentsOf: url)
                    if weekOffset == 0 {
                        return try? JSONDecoder().decode([ScheduleViewModel.Day].self, from: jsonData)
                    } else if weekOffset > 0 {
                        let cacheItem = try JSONDecoder().decode(CacheItem.self, from: jsonData)
                        if TimeManager.shared.validateCache(expirationTime: cacheItem.expirationTime) {
                            return cacheItem.data
                        }
                    }
                } catch {
                    return nil
                }
            }
        }
        
        return nil
    }
    
    private func getFileUrl(for fileName: String) -> URL? {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        if let url = urls.first {
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


}
