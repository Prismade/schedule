import Foundation
import Alamofire

final class SBuildingsManager {
    
    // MARK: - Static Properties
    
    static let shared = SBuildingsManager()
    
    // MARK: - Private Properties
    
    private var buildings = [SBuilding]()
    
    // MARK: Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    func setCoordinates(for building: Int, completion: @escaping (Double?, Double?) -> Void) {
        if buildings.count == 0 {
            if let data = SCacheManager.shared.retrieveBuildings() {
                buildings = data
                if building > 0 {
                    completion(buildings[building - 1].coord[0], buildings[building - 1].coord[1])
                } else {
                    completion(nil, nil)
                }
            } else {
                SApiManager.shared.getBuildingsData { [unowned self] response in
                    switch response.result {
                    case .success(let data):
                        self.buildings = data.corpusData
                        if (building - 1) < self.buildings.count {
                            DispatchQueue.main.async {
                                if building > 0 {
                                    completion(
                                        self.buildings[building - 1].coord[0],
                                        self.buildings[building - 1].coord[1])
                                } else {
                                    completion(nil, nil)
                                }
                            }
                        }
                        do {
                            try SCacheManager.shared.cacheBuildings(data.corpusData)
                        } catch {
                            print("unable to write down buildings data")
                        }
                    default: return
                    }
                }
            }
        } else {
            if building > 0 {
                completion(buildings[building - 1].coord[0], buildings[building - 1].coord[1])
            } else {
                completion(nil, nil)
            }
        }
    }
}
