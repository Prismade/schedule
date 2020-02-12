import Foundation

final class Building: Codable {
    let title: String
    let coord: [Double]
    let address: String
    let img: String
}

final class BuildingData: Codable {
    let corpusData: [Building]
}
