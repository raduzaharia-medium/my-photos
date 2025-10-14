import Foundation

enum Place: Hashable {
    case country(CountryViewModel)
    case locality(LocalityViewModel)
}

struct CountryViewModel: Identifiable, Equatable, Hashable {
    public let id: UUID
    public let key: String
    public let name: String
    public let localities: [LocalityViewModel]
    public var icon: String { "mappin.and.ellipse" }

    init(id: UUID, key: String, name: String, localities: [LocalityViewModel]) {
        self.id = id
        self.key = key
        self.name = name
        self.localities = localities
    }
    init(_ country: PlaceCountry) {
        self.id = country.id
        self.key = country.country
        self.name = country.country
        self.localities = country.localities.map { LocalityViewModel($0) }
            .sorted { $0.name < $1.name }
    }
}

struct LocalityViewModel: Identifiable, Equatable, Hashable {
    public let id: UUID
    public let key: String
    public let name: String
    public var icon: String { "mappin.and.ellipse" }

    init(id: UUID, key: String, name: String) {
        self.id = id
        self.key = key
        self.name = name
    }
    init(_ locality: PlaceLocality) {
        self.id = locality.id
        self.key = locality.locality
        self.name = locality.locality
    }
}
