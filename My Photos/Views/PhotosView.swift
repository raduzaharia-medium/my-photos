//
//  PhotosView.swift
//  My Photos
//
//  Created by Radu Zaharia on 17.08.2025.
//

import SwiftData
import SwiftUI

struct PhotosView: View {
    @Query private var fetched: [Tag]

    init(tagID: PersistentIdentifier) {
        _fetched = Query(
            filter: #Predicate<Tag> { $0.persistentModelID == tagID },
            animation: .default
        )
    }

    var body: some View {
        if let tag = fetched.first {
            Text(tag.name)
        } else {
            ContentUnavailableView(
                "Tag not found",
                systemImage: "tag.slash",
                description: Text("It may have been deleted or moved.")
            )
        }
    }
}
