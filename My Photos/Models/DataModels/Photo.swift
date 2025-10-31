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
    @Attribute(.unique) var key: String
    var title: String
    var caption: String?
    var dateTaken: Date?
    var location: GeoCoordinate?
    var fileName: String
    var path: String
    var bookmark: Data?
    var thumbnailFileName: String

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
        fileName: String,
        path: String,
        bookmark: Data? = nil,
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
        let key = fileName.stablePhotoKey_FNV1a
        
        self.id = id
        self.fileName = fileName
        self.path = path
        self.bookmark = bookmark
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
        self.key = key
        self.thumbnailFileName = "\(key).jpg"
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

extension String {
    var stablePhotoKey_FNV1a: String {
        var h: UInt64 = 1_469_598_103_934_665_603

        for b in self.utf8 {
            h ^= UInt64(b)
            h &*= 1_099_511_628_211
        }

        return String(h, radix: 36, uppercase: false)
    }
}
