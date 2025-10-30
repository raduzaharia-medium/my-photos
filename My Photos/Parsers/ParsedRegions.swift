struct Regions: Equatable, Codable {
    public let appliedToDimensions: AppliedToDimensions
    public let regionList: [Region]
}

struct AppliedToDimensions: Equatable, Codable {
    public let size: Size
    public let unit: String
}

struct Area: Equatable, Codable {
    public let center: Point
    public let size: Size
}

struct Point: Equatable, Codable {
    public let x: Double
    public let y: Double
}

struct Size: Equatable, Codable {
    public let width: Double
    public let height: Double
}

struct Region: Equatable, Codable {
    public let algArea: Area
    public let dlyArea: Area
    public let name: String
    public let nameAssignType: String
    public let type: String
}
