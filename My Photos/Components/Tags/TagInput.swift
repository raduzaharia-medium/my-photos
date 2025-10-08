import SwiftUI

struct TagInput: View {
    @Environment(PresentationState.self) private var presentationState

    @Binding var selected: [Tag]
    @State private var searchText = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var highlightedIndex: Int? = nil

    let title: String
    let kind: TagKind

    private var suggestions: [Tag] {
        return presentationState.getTags(searchText: searchText, kind: kind)
    }

    init(_ title: String, kind: TagKind, selected: Binding<[Tag]>) {
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
                    .focused($isTextFieldFocused)
                    .onSubmit { prepareAddTag() }
                    .arrowKeyNavigation(
                        onUp: { moveHighlight(-1, total: suggestions.count) },
                        onDown: { moveHighlight(1, total: suggestions.count) },
                        onReturn: { submitFromKeyboard() }
                    )
            }
            .contentShape(Rectangle())
            .onTapGesture { isTextFieldFocused = true }
            .cursorIBeamIfAvailable()
            .padding(4)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.quaternary, lineWidth: 1)
            )

            if !searchText.isEmpty {
                TagSuggestions(
                    suggestions: suggestions,
                    highlightedIndex: $highlightedIndex
                ) { tag in
                    addTag(tag)
                }
            }
        }
    }

    private func submitFromKeyboard() {
        if let index = highlightedIndex, suggestions.indices.contains(index) {
            addTag(suggestions[index])
        } else {
            prepareAddTag()
        }
    }
    private func moveHighlight(_ delta: Int, total: Int) {
        let next = (highlightedIndex ?? -1) + delta

        if total > 0 {
            highlightedIndex = min(max(0, next), total - 1)
        } else {
            highlightedIndex = nil
        }
    }

    private func removeTag(_ tag: Tag) {
        withAnimation {
            selected.removeAll { $0.id == tag.id }
        }
    }

    private func prepareAddTag() {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        highlightedIndex = nil
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
            highlightedIndex = nil
        }
    }
}
