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
            isStoredInMemoryOnly: true
        )
        let container = try! ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
        let context = ModelContext(container)

        let tag1 = Tag(name: "Alice", kind: .person)
        let tag2 = Tag(name: "Beach", kind: .place)
        let tag3 = Tag(name: "Birthday", kind: .event)

        context.insert(tag1)
        context.insert(tag2)
        context.insert(tag3)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        context.insert(
            Photo(
                dateTaken: formatter.date(from: "2022-01-09") ?? Date(),
                location: "On the beach",
                tags: [tag1]
            )
        )
        context.insert(
            Photo(
                dateTaken: formatter.date(from: "2022-01-10") ?? Date(),
                location: "On the sea"
            )
        )
        context.insert(
            Photo(
                dateTaken: formatter.date(from: "2022-02-15") ?? Date(),
                location: "On the hill"
            )
        )
        context.insert(
            Photo(
                dateTaken: formatter.date(from: "2022-03-22") ?? Date(),
                location: "Somewhere else"
            )
        )
        context.insert(
            Photo(
                dateTaken: formatter.date(from: "2022-03-25") ?? Date(),
                location: "We don't know"
            )
        )

        return container

    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
