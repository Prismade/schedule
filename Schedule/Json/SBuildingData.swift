import Foundation

final class SBuilding: Codable {
    
    let title: String
    let coord: [Double]
    let address: String
    let img: String
    
}

final class SBuildingData: Codable {
    
    let corpusData: [SBuilding]
    
}
