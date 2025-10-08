import SwiftUI

struct TagInput: View {
    @Environment(PresentationState.self) private var presentationState

    @Binding var selected: [Tag]
    @State private var searchText = ""

    let title: String
    let kind: TagKind
    
    init(title: String, kind: TagKind, selected: Binding<[Tag]>) {
        self.title = title
        self.kind = kind
        self._selected = selected
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            FlowLayout(spacing: 8, lineSpacing: 4) {
                ForEach($selected) { tag in
                    TagChip(
                        tag: tag.wrappedValue,
                        onRemove: { removeTag(tag.wrappedValue) }
                    )
                }

                TextField("", text: $searchText)
                    .padding(.leading, selected.isEmpty ? 6 : 0)
                    .textFieldStyle(.plain)
                    .onSubmit { prepareAddTag() }
            }
            .padding(4)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.quaternary, lineWidth: 1)
            )

            if !searchText.isEmpty {
                Text("Suggestions")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TagSuggestions($searchText, kind: kind) { tag in
                    addTag(tag)
                }
            }
        }
    }

    private func removeTag(_ tag: Tag) {
        withAnimation {
            selected.removeAll { $0.id == tag.id }
        }
    }

    private func prepareAddTag() {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let exact = presentationState.tags.first(where: {
            $0.kind == kind
                && $0.name.compare(trimmed, options: .caseInsensitive)
                    == .orderedSame
        }) {
            addTag(exact)
        } else {
            // TODO: show create action for this kind
        }
    }

    private func addTag(_ tag: Tag) {
        withAnimation {
            if !selected.contains(where: { $0.id == tag.id }) {
                selected.append(tag)
            }
            searchText = ""
        }
    }
}
