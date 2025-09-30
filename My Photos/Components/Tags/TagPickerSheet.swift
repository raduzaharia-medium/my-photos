import SwiftUI

struct TagPickerSheet: View {
    @Environment(PresentationState.self) private var presentationState

    @State private var searchText = ""
    @State private var selectedTags: [Tag] = []

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
            Form {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tags:")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        ForEach(selectedTags) { tag in
                            TagChip(tag: tag) {
                                selectedTags.removeAll { $0.id == tag.id }
                            }
                        }

                        TextField("", text: $searchText)
                            .textFieldStyle(.plain)
                            .onSubmit {
                                let trimmed = searchText.trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                )
                                guard !trimmed.isEmpty else { return }

                                if let exact = presentationState.tags.first(
                                    where: {
                                        $0.name.compare(
                                            trimmed,
                                            options: .caseInsensitive
                                        ) == .orderedSame
                                    })
                                {
                                    addTag(exact)
                                    return
                                }
                                else {
                                    // TODO: show create action
                                }
                            }
                    }
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.quaternary, lineWidth: 1)
                    )
                }

                if !searchText.isEmpty {
                    TagSuggestions($searchText) { tag in
                        addTag(tag)
                    }
                }
            }
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

    private func addTag(_ tag: Tag) {
        if !selectedTags.contains(where: { $0.id == tag.id }) {
            selectedTags.append(tag)
        }

        searchText = ""
    }
}
