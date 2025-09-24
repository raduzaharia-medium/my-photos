import SwiftData
import SwiftUI

struct TagPickerSheet: View {
    @Environment(PresentationState.self) private var presentationState

    @State private var searchText = ""
    @State private var selectedTag: Tag? = nil

    var onSave: (Tag) -> Void
    var onCancel: () -> Void

    init(
        onSave: @escaping (Tag) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        NavigationStack {
            List(selection: $selectedTag) {
                ForEach(TagKind.allCases, id: \.self) { kind in
                    let sectionTags =
                        presentationState.groupedTags[kind] ?? []

                    if !sectionTags.isEmpty {
                        Section(kind.title) {
                            ForEach(sectionTags, id: \.persistentModelID) {
                                tag in
                                SidebarRow(.tag(tag))
                                    .tag(tag)
                            }
                        }
                    }
                }
            }
            .listStyle(.inset)
            .frame(minWidth: 360, minHeight: 420)
            .searchable(text: $searchText, placement: .automatic)
            .navigationTitle("Assign Tag")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", role: .confirm) {
                        if let tag = selectedTag { onSave(tag) }
                    }.keyboardShortcut(.defaultAction)
                        .disabled(selectedTag == nil)
                }
            }
        }
    }
}
