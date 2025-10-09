import SwiftUI

struct TagPickerSheet: View {
    @ObservedObject var people: TagInputState
    @ObservedObject var places: TagInputState
    @ObservedObject var events: TagInputState

    var tags: [Tag] { people.selected + places.selected + events.selected }
    var onSave: ([Tag]) -> Void
    var onCancel: () -> Void

    init(
        people: TagInputState,
        places: TagInputState,
        events: TagInputState,

        onSave: @escaping ([Tag]) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.people = people
        self.places = places
        self.events = events

        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    TagInput("People", state: people)
                    TagInput("Places", state: places)
                    TagInput("Events", state: events)
                }
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
                        if !tags.isEmpty { onSave(tags) }
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(tags.isEmpty)
                }
            }
        }
    }
}
