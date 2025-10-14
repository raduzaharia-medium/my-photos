import Foundation

struct ParsedPhoto {
    let title: String
    let description: String?
    let dateTaken: Date?
    let location: GeoCoordinate?
    let tags: [ParsedTag]
}
