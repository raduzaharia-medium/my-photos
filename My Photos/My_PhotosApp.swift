import SwiftData
import SwiftUI

final class TagSelectionModel: ObservableObject {
    @Published var selection: Set<SidebarItem> = []

    var singleTag: Tag? {
        guard selection.count == 1, case .tag(let t) = selection.first else {
            return nil
        }
        return t
    }

    var allTags: [Tag] {
        selection.compactMap {
            if case .tag(let t) = $0 { return t }
            return nil
        }
    }
}

@main
struct My_PhotosApp: App {
    @StateObject private var modalPresenter = ModalService()
    @StateObject private var alerter = AlertService()
    @StateObject private var fileImporter = FileImportService()
    @StateObject private var notifier = NotificationService()
    @StateObject private var tagSelectionModel = TagSelectionModel()

    private var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Photo.self, Tag.self,
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
                tags: [tag2]
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
    private var tagStore: TagStore {
        TagStore(context: ModelContext(sharedModelContainer))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environmentObject(modalPresenter)
        .environmentObject(alerter)
        .environmentObject(tagStore)
        .environmentObject(fileImporter)
        .environmentObject(notifier)
        .environmentObject(tagSelectionModel)
        .environmentObject(
            EditTagPresenter(
                modalPresenter: modalPresenter,
                notifier: notifier,
                tagStore: tagStore
            )
        )
        .environmentObject(
            ImportPhotosPresenter(
                fileImporter: fileImporter,
                notifier: notifier
            )
        )
        .environmentObject(
            DeleteTagPresenter(
                alerter: alerter,
                notifier: notifier,
                tagStore: tagStore,
                tagSelectionModel: tagSelectionModel
            )
        )
        .modelContainer(sharedModelContainer)
        .commands {
            LibraryCommands(tagSelectionModel)
        }
    }
}
