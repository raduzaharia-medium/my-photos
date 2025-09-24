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
