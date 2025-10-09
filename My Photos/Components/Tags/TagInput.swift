import SwiftUI

struct TagInput: View {
    @Environment(PresentationState.self) private var presentationState
    @FocusState private var isTextFieldFocused: Bool
    @Binding var state: TagInputState

    var suggestions: [Tag] {
        return presentationState.getTags(
            searchText: state.searchText,
            kind: state.kind
        )
    }

    let title: String

    init(_ title: String, state: Binding<TagInputState>) {
        self.title = title
        self._state = state
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            FlowLayout(spacing: 8, lineSpacing: 4) {
                ForEach(state.selected) { tag in
                    TagChip(
                        tag: tag,
                        onRemove: { state.removeTag(tag) }
                    )
                }

                TextField("", text: $state.searchText)
                    .padding(.leading, state.selected.isEmpty ? 6 : 0)
                    .textFieldStyle(.plain)
                    .focused($isTextFieldFocused)
                    .onSubmit { state.submitFromKeyboard(suggestions) }
                    .arrowKeyNavigation(
                        onUp: { state.highlightPrevious(suggestions.count) },
                        onDown: { state.highlightNext(suggestions.count) },
                        onReturn: { state.submitFromKeyboard(suggestions) }
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

            if !state.searchText.isEmpty {
                TagSuggestions(
                    suggestions: suggestions,
                    highlightedIndex: $state.highlightedIndex
                ) { tag in
                    state.addTag(tag)
                }
            }
        }
    }
}
