import SwiftData
import SwiftUI

@main
struct My_PhotosApp: App {
    @StateObject private var tagViewModel = TagViewModel()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Photo.self, Tag.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
       
        let container: ModelContainer
        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
        
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
                title: "On the beach",
                dateTaken: formatter.date(from: "2022-01-09") ?? Date(),
                location: GeoCoordinate(44.439663, 26.096306),
                tags: [tag1]
            )
        )
        context.insert(
            Photo(
                title: "On the sea",
                dateTaken: formatter.date(from: "2022-01-10") ?? Date(),
                location: GeoCoordinate(46.770439, 23.591423),
            )
        )
        context.insert(
            Photo(
                title: "On the hill",
                dateTaken: formatter.date(from: "2022-02-15") ?? Date(),
                location: GeoCoordinate(47.158455, 27.601442),
            )
        )
        context.insert(
            Photo(
                title: "Somewhere else",
                dateTaken: formatter.date(from: "2022-03-22") ?? Date(),
                location: GeoCoordinate(44.319305, 23.800678),
            )
        )
        context.insert(
            Photo(
                title: "We don't know",
                dateTaken: formatter.date(from: "2022-03-25") ?? Date(),
                location: GeoCoordinate(45.657974, 25.601198),
            )
        )

        return container
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(tagViewModel)
        }
        .modelContainer(sharedModelContainer)
        .commands {
            SidebarCommands(tagViewModel)
        }
    }
}
