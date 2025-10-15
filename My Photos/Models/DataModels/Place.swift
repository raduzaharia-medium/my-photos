import Foundation
import SwiftData

@Model
final class PlaceCountry: Identifiable, Equatable {
    @Attribute(.unique) var id = UUID()
    @Attribute(.unique) var key: String
    @Attribute(.unique) var country: String

    @Relationship(deleteRule: .cascade, inverse: \PlaceLocality.country)
    var localities: [PlaceLocality] = []
    @Relationship(inverse: \Photo.country) var photos: [Photo] = []

    init(_ country: String) {
        self.country = country
        self.key = country
    }

    static func == (left: PlaceCountry, right: PlaceCountry) -> Bool {
        left.key == right.key
    }
}

@Model
final class PlaceLocality: Identifiable, Equatable {
    @Attribute(.unique) var id = UUID()
    @Attribute(.unique) var key: String

    var locality: String

    @Relationship var country: PlaceCountry
    @Relationship(inverse: \Photo.locality) var photos: [Photo] = []

    init(_ country: PlaceCountry, _ locality: String) {
        self.locality = locality
        self.country = country
        self.key = "\(country.key)-\(locality)"
    }

    static func == (left: PlaceLocality, right: PlaceLocality) -> Bool {
        left.key == right.key
    }
}

enum Place: Hashable {
    case country(PlaceCountry)
    case locality(PlaceLocality)
}

extension PlaceCountry {
    var icon: String { return "mappin.and.ellipse" }
}

extension PlaceLocality {
    var icon: String { return "mappin.and.ellipse" }
}
