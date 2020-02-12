import Foundation
import Alamofire


final class BuildingsManager {
    
    static let shared = BuildingsManager()
    
    private init() {}
    
    private var buildings = [Building]()
    
    func setCoordinates(for building: Int, completion: @escaping (Double, Double) -> Void) {
        if buildings.count == 0 {
            if let data = CacheManager.shared.retrieveBuildings() {
                buildings = data
                completion(buildings[building - 1].coord[0], buildings[building - 1].coord[1])
            } else {
                ApiManager.shared.getBuildingsData { [unowned self] response in
                    switch response.result {
                    case .success(let data):
                        self.buildings = data.corpusData
                        if (building - 1) < self.buildings.count {
                            DispatchQueue.main.async {
                                completion(self.buildings[building - 1].coord[0], self.buildings[building - 1].coord[1])
                            }
                        }
                        do {
                            try CacheManager.shared.cacheBuildings(data.corpusData)
                        } catch {
                            print("unable to write down buildings data")
                        }
                    default: return
                    }
                }
            }
        } else {
            completion(buildings[building - 1].coord[0], buildings[building - 1].coord[1])
        }
    }
}
