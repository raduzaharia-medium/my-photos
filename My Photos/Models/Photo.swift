//
//  Photo.swift
//  My Photos
//
//  Created by Radu Zaharia on 16.08.2025.
//

import SwiftData
import Foundation

@Model
final class Photo {
    @Attribute(.unique) var id: UUID
    var dateTaken: Date
    var location: String
    
    @Relationship(inverse: \Tag.photos) var tags: [Tag] = []
    
    public init(
        id: UUID = .init(),
        dateTaken: Date,
        location: String
    ) {
        self.id = id
        self.dateTaken = dateTaken
        self.location = location
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
