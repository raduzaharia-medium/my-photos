import SwiftUI

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
                }

                Section(kind.title) {
                    ForEach(
                        roots.sorted {
                            $0.name.localizedCaseInsensitiveCompare($1.name)
                                == .orderedAscending
                        },
                        id: \.persistentModelID
                    ) { root in
                        TagTree(tag: root, kind: kind)
                    }
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
