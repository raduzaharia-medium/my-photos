import SwiftData
import SwiftUI

@main
struct My_PhotosApp: App {
    @State private var presentationState = PresentationState()
    @State private var tagPickerState = TagPickerState()

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

        let tag3 = Tag(name: "Birthday", kind: .event)
        let tag4 = Tag(name: "Something", kind: .custom)
        let tag5 = Tag(name: "Something else", kind: .custom)
        let tag6 = Tag(name: "With-Dash", kind: .custom)
        let tag7 = Tag(name: "Nothing", kind: .custom)

        context.insert(tag3)
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
                title: "On the beach",
                dateTaken: formatter.date(from: "2022-01-09") ?? Date(),
                dateTakenYear: year2022,
                dateTakenMonth: month202201,
                dateTakenDay: day20220109,
                location: GeoCoordinate(44.439663, 26.096306),
                album: album,
                people: [alice],
            )
        )
        context.insert(
            Photo(
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
                title: "We don't know",
                dateTaken: formatter.date(from: "2022-03-25") ?? Date(),
                dateTakenYear: year2022,
                dateTakenMonth: month202203,
                dateTakenDay: day20220325,
                location: GeoCoordinate(45.657974, 25.601198),
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
        .environment(tagPickerState)
        .commands {
            LibraryCommands(presentationState: $presentationState)
        }
    }
}
