import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension View {
    func setupFilterHandlers(
        presentationState: PresentationState,
        notifier: NotificationService,
        confirmer: ConfirmationService,
        albumStore: AlbumStore,
        personStore: PersonStore,
        eventStore: EventStore,
        tagStore: TagStore
    ) -> some View {
        let deleteFilterPresenter = DeleteFilterPresenter(confirmer: confirmer)

        let deleteMany: (NotificationCenter.Publisher.Output) async -> Void = {
            note in
            guard let filters = note.object as? [SidebarItem] else { return }

            do {
                let albums = filters.compactMap { item -> Album? in
                    if case .album(let album) = item { album } else { nil }
                }
                let people = filters.compactMap { item -> Person? in
                    if case .person(let person) = item { person } else { nil }
                }
                let events = filters.compactMap { item -> Event? in
                    if case .event(let event) = item { event } else { nil }
                }
                let tags = filters.compactMap { item -> Tag? in
                    if case .tag(let tag) = item { tag } else { nil }
                }

                try await albumStore.delete(albums.map(\.id))
                try await personStore.delete(people.map(\.id))
                try await eventStore.delete(events.map(\.id))
                try await tagStore.delete(tags.map(\.id))
                
                presentationState.photoFilter = []
                
                notifier.show("Filters deleted", .success)
            } catch {
                notifier.show("Could not delete filters", .error)
            }
        }
        let showManyRemover: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let filters = note.object as? [SidebarItem] else { return }
            deleteFilterPresenter.show(filters)
        }

        return
            self
            .onReceive(
                NotificationCenter.default.publisher(for: .deleteFilters)
            ) { note in
                Task { await deleteMany(note) }
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: .requestDeleteFilters
                ),
                perform: showManyRemover
            )
    }
}
