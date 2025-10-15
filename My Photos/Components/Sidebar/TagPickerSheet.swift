import SwiftUI

struct TagPickerSheet: View {
    @Environment(TagPickerState.self) private var tagPickerState

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
//                    TagInput("People", kind: .person)
//                    TagInput("Places", kind: .place)
//                    TagInput("Events", kind: .event)
                }
            }
            .onAppear() {
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
