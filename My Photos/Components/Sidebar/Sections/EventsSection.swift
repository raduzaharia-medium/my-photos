import SwiftData
import SwiftUI

struct EventsSection: View {
    @Query(sort: \Event.key) private var events: [Event]

    var body: some View {
        Section("Events") {
            ForEach(events) { event in
                SidebarRow(.event(event)).tag(event)
                    .dropDestination(for: PhotoDragItem.self) { items, _ in
                        PhotoIntents.requestChangeEvent(event: event)
                        return true
                    }
            }
        }
    }
}
