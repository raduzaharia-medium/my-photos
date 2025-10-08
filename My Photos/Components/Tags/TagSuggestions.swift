import SwiftUI

struct TagSuggestions: View {
    @Binding var highlightedIndex: Int?
    
    private var suggestions: [Tag]
    private var onSelect: ((Tag) -> Void)?
    
    init(
        suggestions: [Tag],
        highlightedIndex: Binding<Int?> = .constant(nil),
        onSelect: ((Tag) -> Void)? = nil
    ) {
        self.suggestions = suggestions
        self._highlightedIndex = highlightedIndex
        self.onSelect = onSelect
    }

    var body: some View {
        let matches = suggestions

        return VStack(alignment: .leading, spacing: 8) {
            if matches.isEmpty {
                Text("No matching tags")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(matches.indices, id: \.self) { index in
                    let tag = matches[index]
                    let isHighlighted = (index == highlightedIndex)

                    Button {
                        onSelect?(tag)
                    } label: {
                        Label(tag.name, systemImage: tag.kind.icon)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 8)
                            .background(isHighlighted ? Color.accentColor.opacity(0.15) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
