import SwiftUI
import SwiftData

struct SidebarView: View {
    @Environment(PresentationState.self) private var presentationState
    @State private var selection: Set<SidebarItem> = []
    @Query(sort: \Tag.name, order: .forward) private var tags: [Tag]

    private var groups: [TagKind: [Tag]] {
        Dictionary(grouping: tags, by: { $0.kind })
    }

    var body: some View {
        List(selection: $selection) {
            Section("Filters") {
                ForEach(Filter.allCases, id: \.self) { filter in
                    SidebarRow(.filter(filter))
                }
            }

            ForEach(TagKind.allCases, id: \.self) { kind in
                let sectionTags = groups[kind] ?? []

                if !sectionTags.isEmpty {
                    Section(kind.title) {
                        ForEach(sectionTags, id: \.persistentModelID) { tag in
                            SidebarRow(.tag(tag))
                        }
                    }
                }
            }
        }
        .task {
            AppIntents.resetTagSelection()
        }
        .setupSidebarHandlers(selection: $selection, filters: Filter.allCases)
        .onChange(of: selection) { oldValue, newValue in
            presentationState.photoFilter = newValue
        }
        #if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 300)
        #endif
        .contextMenu(forSelectionType: SidebarItem.self) { items in
            TagContextMenu(items)
        }
        .toolbar {
            TagToolbar()
        }
    }
}
