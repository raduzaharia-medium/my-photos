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
    var dateTaken: Date
    var location: GeoCoordinate
    
    @Relationship(inverse: \Tag.photos) var tags: [Tag]
    
    public init(
        id: UUID = .init(),
        title: String,
        dateTaken: Date,
        location: GeoCoordinate,
        tags: [Tag] = []
    ) {
        self.id = id
        self.title = title
        self.dateTaken = dateTaken
        self.location = location
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

extension Collection where Element == Photo {
    func filtered(by sidebarSelection: Set<SidebarItem>) -> [Photo] {
        let selectedTags: [Tag] = sidebarSelection.compactMap {
            if case .tag(let t) = $0 { return t }
            return nil
        }

        guard !selectedTags.isEmpty else {
            return Array(self)
        }

        let filtered = self.filter { photo in
            photo.tags.contains { tag in
                selectedTags.contains(where: { $0 == tag })
            }
        }

        return filtered.sorted { $0.dateTaken > $1.dateTaken }
    }
}
