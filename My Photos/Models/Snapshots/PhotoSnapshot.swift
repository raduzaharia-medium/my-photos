import Foundation

struct PhotoSnapshot: Sendable, Codable, Equatable, Hashable {
    let id: UUID?
    let key: String
    let title: String
    let caption: String?
    let dateTaken: Date?
    let location: GeoCoordinate?
    let fileName: String
    let path: String
    let fullPath: String
    let creationDate: Date?
    let lastModifiedDate: Date?
    let bookmark: Data?
    let thumbnailFileName: String?

    let tags: [UUID]
    let dateTakenYear: UUID?
    let dateTakenMonth: UUID?
    let dateTakenDay: UUID?
    let country: UUID?
    let locality: UUID?
    let albums: [UUID]
    let people: [UUID]
    let events: [UUID]
}
