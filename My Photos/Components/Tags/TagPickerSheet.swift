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
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        FlowLayout(spacing: 8, lineSpacing: 4) {
                            ForEach(selectedTags) { tag in
                                TagChip(tag: tag, onRemove: { removeTag(tag) })

                            }

                            TextField("", text: $searchText)
                                .padding(.leading, selectedTags.isEmpty ? 6 : 0)
                                .textFieldStyle(.plain)
                                .onSubmit { prepareAddTag() }
                        }
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.quaternary, lineWidth: 1)
                        )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        if !searchText.isEmpty {
                            Text("Suggestions")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            TagSuggestions($searchText) { tag in
                                addTag(tag)
                            }
                        }
                    }
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

    private func removeTag(_ tag: Tag) {
        withAnimation {
            selectedTags.removeAll {
                $0.id == tag.id
            }
        }
    }
    
    private func prepareAddTag() {
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
        } else {
            // TODO: show create action
        }
    }

    private func addTag(_ tag: Tag) {
        withAnimation {
            if !selectedTags.contains(where: { $0.id == tag.id }) {
                selectedTags.append(tag)
            }

            searchText = ""
        }
    }
}
