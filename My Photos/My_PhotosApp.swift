//
//  My_PhotosApp.swift
//  My Photos
//
//  Created by Radu Zaharia on 16.08.2025.
//

import SwiftData
import SwiftUI

@main
struct My_PhotosApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Photo.self, Tag.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        let container = try! ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
        let context = ModelContext(container)

        context.insert(Tag(name: "Alice", kind: .person))
        context.insert(Tag(name: "Beach", kind: .place))
        context.insert(Tag(name: "Birthday", kind: .event))

        return container

    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
