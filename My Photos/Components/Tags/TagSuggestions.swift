import SwiftUI

struct TagSuggestions: View {
    @Environment(PresentationState.self) private var presentationState

    private var searchText: Binding<String>
    private var kind: TagKind
    private var onSelect: ((Tag) -> Void)?

    private var allTags: [Tag] {
        presentationState.tags.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name)
                == .orderedAscending
        }
    }
    private var filteredTags: [Tag] {
        if searchText.wrappedValue.isEmpty { return allTags }
        return allTags.filter {
            $0.name.localizedCaseInsensitiveContains(searchText.wrappedValue)
        }
    }

    init(
        _ searchText: Binding<String>,
        kind: TagKind = .custom,
        onSelect: ((Tag) -> Void)? = nil
    ) {
        self.searchText = searchText
        self.kind = kind
        self.onSelect = onSelect
    }

    var body: some View {
        let matches = filteredTags.filter {
            $0.name.lowercased().contains(searchText.wrappedValue.lowercased())
                && $0.kind == kind
        }

        return VStack(alignment: .leading, spacing: 8) {
            if matches.isEmpty {
                Text("No matching tags")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(matches) { tag in
                    Button {
                        if let onSelect {
                            onSelect(tag)
                        } else {
                            searchText.wrappedValue = tag.name
                        }
                    } label: {
                        Label(tag.name, systemImage: tag.kind.icon)
                    }
                }
            }
        }
    }
}
