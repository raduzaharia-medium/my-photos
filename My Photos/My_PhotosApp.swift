import SwiftData
import SwiftUI

@main
struct My_PhotosApp: App {
    @State private var presentationState = PresentationState()

    private var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Photo.self, Tag.self, DateTakenYear.self, DateTakenMonth.self,
            DateTakenDay.self, PlaceCountry.self, PlaceLocality.self,
            Album.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        let container: ModelContainer
        do {
            container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }

        let context = ModelContext(container)
        
        let alice = Person("Alice")
        let birthday = Event("Birthday")
        
        let tag4 = Tag(name: "Something")
        let tag5 = Tag(name: "Something else")
        let tag6 = Tag(name: "With-Dash")
        let tag7 = Tag(name: "Nothing")

        context.insert(tag4)
        context.insert(tag5)
        context.insert(tag6)
        context.insert(tag7)

        let countryRomania = PlaceCountry("Romania")
        let localityBucharest = PlaceLocality(countryRomania, "Bucharest")

        let year2022 = DateTakenYear(2022)
        let month202201 = DateTakenMonth(year2022, 1)
        let day20220109 = DateTakenDay(month202201, 9)
        let day20220110 = DateTakenDay(month202201, 10)
        let month202202 = DateTakenMonth(year2022, 2)
        let day20220215 = DateTakenDay(month202202, 15)
        let month202203 = DateTakenMonth(year2022, 3)
        let day20220322 = DateTakenDay(month202203, 22)
        let day20220325 = DateTakenDay(month202203, 25)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        let album = Album("My album")

        context.insert(
            Photo(
                fileName: "beach.jpg",
                path: "/path/to/beach.jpg",
                fullPath: "/path/to/beach.jpg",
                title: "On the beach",
                dateTaken: formatter.date(from: "2022-01-09") ?? Date(),
                dateTakenYear: year2022,
                dateTakenMonth: month202201,
                dateTakenDay: day20220109,
                location: GeoCoordinate(44.439663, 26.096306),
                albums: [album],
                people: [alice],
            )
        )
        context.insert(
            Photo(
                fileName: "on-the-sea.jpg",
                path: "/path/to/on-the-sea.jpg",
                fullPath: "/path/to/on-the-sea.jpg",
                title: "On the sea",
                dateTaken: formatter.date(from: "2022-01-10") ?? Date(),
                dateTakenYear: year2022,
                dateTakenMonth: month202201,
                dateTakenDay: day20220110,
                location: GeoCoordinate(46.770439, 23.591423),
                country: countryRomania,
                locality: localityBucharest,
            )
        )
        context.insert(
            Photo(
                fileName: "on-the-hill.jpg",
                path: "/path/to/on-the-hill.jpg",
                fullPath: "/path/to/on-the-hill.jpg",
                title: "On the hill",
                dateTaken: formatter.date(from: "2022-02-15") ?? Date(),
                dateTakenYear: year2022,
                dateTakenMonth: month202202,
                dateTakenDay: day20220215,
                location: GeoCoordinate(47.158455, 27.601442),
            )
        )
        context.insert(
            Photo(
                fileName: "somewhere-else.jpg",
                path: "/path/to/somewhere-else.jpg",
                fullPath: "/path/to/somewhere-else.jpg",
                title: "Somewhere else",
                dateTaken: formatter.date(from: "2022-03-22") ?? Date(),
                dateTakenYear: year2022,
                dateTakenMonth: month202203,
                dateTakenDay: day20220322,
                location: GeoCoordinate(44.319305, 23.800678),
            )
        )
        context.insert(
            Photo(
                fileName: "we-don-t-know.jpg",
                path: "/path/to/we-don-t-know.jpg",
                fullPath: "/path/to/we-don-t-know.jpg",
                title: "We don't know",
                dateTaken: formatter.date(from: "2022-03-25") ?? Date(),
                dateTakenYear: year2022,
                dateTakenMonth: month202203,
                dateTakenDay: day20220325,
                location: GeoCoordinate(45.657974, 25.601198),
                events: [birthday]
            )
        )

        return container
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .environment(presentationState)
        .commands {
            LibraryCommands(presentationState: $presentationState)
        }
    }
}
