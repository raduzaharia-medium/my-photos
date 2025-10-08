import SwiftUI

struct TagPickerSheet: View {
    @State private var people: [Tag] = []
    @State private var places: [Tag] = []
    @State private var events: [Tag] = []

    var tags: [Tag] { people + places + events }
    var onSave: ([Tag]) -> Void
    var onCancel: () -> Void

    init(
        onSave: @escaping ([Tag]) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    TagInput("People", kind: .person, selected: $people)
                    TagInput("Places", kind: .place, selected: $places)
                    TagInput("Events", kind: .event, selected: $events)
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
