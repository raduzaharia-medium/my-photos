import Foundation
import SwiftData

@Model
final class PlaceCountry: Identifiable, Hashable, Equatable {
    @Attribute(.unique) var id = UUID()
    @Attribute(.unique) var key: String
    @Attribute(.unique) var country: String

    @Relationship(deleteRule: .cascade, inverse: \PlaceLocality.country)
    var localities: [PlaceLocality] = []
    @Relationship(inverse: \Photo.country) var photos: [Photo] = []

    init(_ country: String) {
        self.country = country
        self.key = PlaceCountry.key(country)
    }

    static func == (left: PlaceCountry, right: PlaceCountry) -> Bool {
        left.key == right.key
    }

    static func key(_ country: String) -> String { country }
}

@Model
final class PlaceLocality: Identifiable, Hashable, Equatable {
    @Attribute(.unique) var id = UUID()
    @Attribute(.unique) var key: String

    var locality: String

    @Relationship var country: PlaceCountry
    @Relationship(inverse: \Photo.locality) var photos: [Photo] = []

    init(_ country: PlaceCountry, _ locality: String) {
        self.locality = locality
        self.country = country
        self.key = PlaceLocality.key(country, locality)
    }

    static func == (left: PlaceLocality, right: PlaceLocality) -> Bool {
        left.key == right.key
    }

    static func key(_ country: PlaceCountry, _ locality: String) -> String {
        "\(country.key)-\(locality)"
    }
    static func key(_ country: String, _ locality: String) -> String {
        "\(PlaceCountry.key(country))-\(locality)"
    }
}

enum Place: Hashable {
    case country(PlaceCountry)
    case locality(PlaceLocality)

    static let icon: String = "mappin.and.ellipse"
}

extension PlaceCountry {
    static let icon: String = "mappin.and.ellipse"
}

extension PlaceLocality {
    static let icon: String = "mappin.and.ellipse"
}
