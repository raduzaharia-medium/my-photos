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

@Model
final class Photo: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var caption: String?
    var dateTaken: Date?
    var location: GeoCoordinate?
    
    @Relationship(inverse: \Tag.photos) var tags: [Tag]
    @Relationship var dateTakenYear: DateTakenYear?
    @Relationship var dateTakenMonth: DateTakenMonth?
    @Relationship var dateTakenDay: DateTakenDay?
    @Relationship var country: PlaceCountry?
    @Relationship var locality: PlaceLocality?
    @Relationship var album: Album?
    
    public init(
        id: UUID = .init(),
        title: String,
        description: String? = nil,
        dateTaken: Date?,
        dateTakenYear: DateTakenYear? = nil,
        dateTakenMonth: DateTakenMonth? = nil,
        dateTakenDay: DateTakenDay? = nil,
        location: GeoCoordinate? = nil,
        country: PlaceCountry? = nil,
        locality: PlaceLocality? = nil,
        album: Album? = nil,
        tags: [Tag] = [],
    ) {
        self.id = id
        self.title = title
        self.caption = description
        self.dateTaken = dateTaken
        self.dateTakenYear = dateTakenYear
        self.dateTakenMonth = dateTakenMonth
        self.dateTakenDay = dateTakenDay
        self.location = location
        self.country = country
        self.locality = locality
        self.album = album
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

