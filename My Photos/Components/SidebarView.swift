import SwiftUI
import SwiftData

struct SidebarView: View {
    @Environment(PresentationState.self) private var presentationState
    @Query(sort: \Tag.name, order: .forward) private var tags: [Tag]

    private var groups: [TagKind: [Tag]] {
        Dictionary(grouping: tags, by: { $0.kind })
    }

    private var selectionBinding: Binding<Set<SidebarItem>> {
        Binding(
            get: { presentationState.photoFilter },
            set: { newValue in
                AppIntents.updatePhotoFilter(newValue)
            }
        )
    }

    var body: some View {
        List(selection: selectionBinding) {
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
            AppIntents.resetPhotoFilter()
        }
        .setupSidebarHandlers(presentationState: presentationState)
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
