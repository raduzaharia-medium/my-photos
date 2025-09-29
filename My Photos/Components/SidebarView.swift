import SwiftUI
import UniformTypeIdentifiers

struct SidebarView: View {
    @Environment(PresentationState.self) private var presentationState

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
                let sectionTags = presentationState.groupedTags[kind] ?? []
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
                .dropDestination(for: TagDragItem.self) { items, _ in
                    guard let incoming = items.first else { return false }
                    guard
                        let dragged = presentationState.tags.first(where: {
                            $0.name == incoming.name && $0.kind == incoming.kind
                        })
                    else { return false }
                  
                    AppIntents.editTag(dragged, name: dragged.name, kind: kind)
                    AppIntents.loadTags()
                    
                    return true
                } isTargeted: { _ in
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
