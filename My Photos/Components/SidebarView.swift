import SwiftUI
import UniformTypeIdentifiers

struct SidebarView: View {
    @Environment(PresentationState.self) private var state

    private var selectionBinding: Binding<Set<SidebarItem>> {
        Binding(
            get: { state.photoFilter },
            set: { newValue in
                AppIntents.updatePhotoFilter(newValue)
            }
        )
    }

    var body: some View {
        List(selection: selectionBinding) {
            FiltersSection()
            DatesSection()
            PlacesSection()
            AlbumsSection()
            
            ForEach(TagKind.allCases, id: \.self) { kind in
                let sectionTags = state.groupedTags[kind] ?? []
                let roots = sectionTags.filter {
                    $0.parent == nil || $0.parent?.kind != kind
                }.sorted {
                    $0.name.localizedCaseInsensitiveCompare($1.name)
                        == .orderedAscending
                }

                Section(kind.title) {
                    ForEach(roots) { root in
                        TagTree(tag: root, kind: kind)
                    }
                }
                .dropDestination(for: TagDragItem.self, isEnabled: true) {
                    items,
                    _ in
                    for incoming in items {
                        let dragged = state.getTag(incoming.id)
                        guard let dragged else { return }

                        AppIntents.editTag(
                            dragged,
                            name: dragged.name,
                            kind: kind
                        )
                    }

                    AppIntents.loadTags()
                }
            }
        }
        .task {
            AppIntents.resetPhotoFilter()
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
