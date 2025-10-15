import SwiftUI

struct AlbumEditorSheet: View {
    @FocusState private var nameFocused: Bool
    @State private var name: String

    let album: Album?

    var title: String { album == nil ? "New Album" : "Edit Album" }
    var trim: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    var canSave: Bool { !trim.isEmpty }

    var onSave: (Album?, String) -> Void
    var onCancel: () -> Void

    init(
        _ album: Album? = nil,
        onSave: @escaping (Album?, String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.album = album
        self.onSave = onSave
        self.onCancel = onCancel

        _name = State(initialValue: album?.name ?? "")
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Name").font(.caption).foregroundStyle(.secondary)
                TextField("e.g. Winter Vacation, Kittens", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .focused($nameFocused)
                    .submitLabel(.done)
                    .onSubmit { onSave(album, trim) }
            }.padding(20)
                .task { nameFocused = true }
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) { onCancel() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save", role: .confirm) {
                            onSave(album, trim)
                        }.keyboardShortcut(.defaultAction)
                            .disabled(!canSave)
                    }
                }
                .interactiveDismissDisabled(!canSave)
        }
    }
}
