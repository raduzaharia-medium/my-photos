import SwiftUI

struct TagPickerSheet: View {
    @State private var selectedAlbums: Set<Album> = []
    @State private var selectedPeople: Set<Person> = []
    @State private var selectedEvents: Set<Event> = []
    @State private var selectedTags: Set<Tag> = []

    let photos: [Photo]

    private var allItems: [SidebarItem] {
        let albumItems = Set(selectedAlbums.map { SidebarItem.album($0) })
        let peopleItems = Set(selectedPeople.map { SidebarItem.person($0) })
        let eventItems = Set(selectedEvents.map { SidebarItem.event($0) })
        let tagItems = Set(selectedTags.map { SidebarItem.tag($0) })

        return Array(
            albumItems.union(peopleItems).union(eventItems).union(tagItems)
        )
    }

    var onSave: ([Photo], [SidebarItem]) -> Void
    var onCancel: () -> Void

    init(
        photos: [Photo],

        onSave: @escaping ([Photo], [SidebarItem]) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.photos = photos

        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    AlbumInput(selection: $selectedAlbums)
                    PersonInput(selection: $selectedPeople)
                    EventInput(selection: $selectedEvents)
                    TagInput(selection: $selectedTags)
                }
            }
            .padding(20)
            .frame(minWidth: 360, minHeight: 300)
            .navigationTitle("Assign Tags")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", role: .confirm) {
                        guard !allItems.isEmpty else { return }
                        onSave(photos, allItems)
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(allItems.isEmpty)
                }
            }
        }.onAppear {
            for photo in photos {
                for album in photo.albums { selectedAlbums.insert(album) }
                for person in photo.people { selectedPeople.insert(person) }
                for event in photo.events { selectedEvents.insert(event) }
                for tag in photo.tags { selectedTags.insert(tag) }
            }
        }
    }
}
