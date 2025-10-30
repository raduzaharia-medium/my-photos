import Foundation

struct ParsedPhoto {
    let title: String
    let description: String?
    let dateTaken: Date?
    let location: GeoCoordinate?
    let country: String?
    let locality: String?
    let tags: [ParsedTag]
    let albums: [String]
}
