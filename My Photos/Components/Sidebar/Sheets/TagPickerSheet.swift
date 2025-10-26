import SwiftUI

struct TagPickerSheet: View {
    @Environment(TagPickerState.self) private var tagPickerState
    @State private var selectedAlbums: Set<Album> = []
    @State private var selectedPeople: Set<Person> = []
    @State private var selectedEvents: Set<Event> = []
    @State private var selectedTags: Set<Tag> = []

    var onSave: (Set<Tag>) -> Void
    var onCancel: () -> Void

    init(
        onSave: @escaping (Set<Tag>) -> Void,
        onCancel: @escaping () -> Void
    ) {
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
            .onAppear {
                tagPickerState.tags.removeAll()
                tagPickerState.selectedIndex = nil
            }
            .padding(20)
            .frame(minWidth: 360, minHeight: 300)
            .navigationTitle("Assign Tag")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", role: .confirm) {
                        guard !tagPickerState.tags.isEmpty else { return }
                        onSave(tagPickerState.tags)
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(tagPickerState.tags.isEmpty)
                }
            }
        }
    }
}
