import SwiftUI

struct TagPickerSheet: View {
    @Environment(PresentationState.self) private var presentationState

    @State private var searchText = ""
    
    @State private var selectedPeople: [Tag] = []
    @State private var selectedPlaces: [Tag] = []
    @State private var selectedEvents: [Tag] = []
    
    var selectedTags: [Tag] {
        selectedPeople + selectedPlaces + selectedEvents
    }
    
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
                    TagInput(title: "People", kind: .person, selected: $selectedPeople)
                    TagInput(title: "Places", kind: .place, selected: $selectedPlaces)
                    TagInput(title: "Events", kind: .event, selected: $selectedEvents)
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
                        if !selectedTags.isEmpty { onSave(selectedTags) }
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(selectedTags.isEmpty)
                }
            }
        }
    }
}
