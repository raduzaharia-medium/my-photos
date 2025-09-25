import SwiftData
import Foundation

struct GeoCoordinate: Codable, Hashable {
    let latitude: Double
    let longitude: Double
    
    init(_ latitude: Double, _ longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

struct Place: Codable, Hashable {
    var city: String?
    var country: String?
}

@Model
final class Photo: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var dateTaken: Date?
    var location: GeoCoordinate?
    var place: Place?
    
    @Relationship(inverse: \Tag.photos) var tags: [Tag]
    
    public init(
        id: UUID = .init(),
        title: String,
        dateTaken: Date?,
        location: GeoCoordinate? = nil,
        place: Place? = nil,
        tags: [Tag] = [],
    ) {
        self.id = id
        self.title = title
        self.dateTaken = dateTaken
        self.location = location
        self.place = place
        self.tags = tags
    }
    
    func addTag(_ tag: Tag) {
        if (!tags.contains {$0.persistentModelID == tag.persistentModelID} ) {
            tags.append(tag)
        }
    }
    
    func removeTag(_ tag: Tag) {
        tags.removeAll {
            $0.persistentModelID == tag.persistentModelID
        }
    }
}

