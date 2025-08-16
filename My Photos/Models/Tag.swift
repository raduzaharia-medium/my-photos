//
//  Tag.swift
//  My Photos
//
//  Created by Radu Zaharia on 16.08.2025.
//

import SwiftData

enum TagKind: Int, Codable, Hashable, CaseIterable {
    case person = 0
    case place = 1
    case date = 2
    case event = 3
    case custom = 4
}

extension TagKind {
    var title: String {
        switch self {
        case .person: "People"
        case .place: "Places"
        case .date: "Dates"
        case .event: "Events"
        case .custom: "Others"
        }
    }
    
    var icon: String {
        switch self {
        case .person: "person"
        case .place: "mappin.and.ellipse"
        case .date: "calendar"
        case .event: "event"
        case .custom: "tag"
        }
    }
}

@Model
final class Tag {
    var name: String
    var kind: TagKind
    
    @Relationship(inverse: \Tag.parent) var children: [Tag] = []
    @Relationship var parent: Tag?
    @Relationship var photos: [Photo] = []
    
    public init(name: String, kind: TagKind, parent: Tag? = nil) {
        self.name = name
        self.kind = kind
        self.parent = parent
    }
}
