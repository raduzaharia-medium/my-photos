import Foundation
import SwiftData

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
    @Relationship var albums: [Album]
    @Relationship var people: [Person]
    @Relationship var events: [Event]

    var isRecent: Bool {
        guard let dateTaken else { return false }
        let pastThreeMonths = Date().addingTimeInterval(-60 * 60 * 24 * 90)

        return dateTaken >= pastThreeMonths
    }

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
        albums: [Album] = [],
        people: [Person] = [],
        events: [Event] = [],
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
        self.albums = albums
        self.people = people
        self.events = events
        self.tags = tags
    }
    
    func addAlbum(_ album: Album) {
        if !self.albums.contains(where: { $0.id == album.id }) {
            self.albums.append(album)
        }
    }
    func addPerson(_ person: Person) {
        if !self.people.contains(where: { $0.id == person.id }) {
            self.people.append(person)
        }
    }
    func addEvent(_ event: Event) {
        if !self.events.contains(where: { $0.id == event.id }) {
            self.events.append(event)
        }
    }
    func addTag(_ tag: Tag) {
        if !self.tags.contains(where: { $0.id == tag.id }) {
            self.tags.append(tag)
        }
    }
}
