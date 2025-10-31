import Foundation

struct ParsedPhoto {
    let path: URL
    let title: String
    let description: String?
    let dateTaken: Date?
    let location: GeoCoordinate?
    let country: String?
    let locality: String?
    let tags: [ParsedTag]
    let albums: [String]
    let regions: ParsedRegions?
}
