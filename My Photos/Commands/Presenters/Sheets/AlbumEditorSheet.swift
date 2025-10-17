import SwiftUI

struct AlbumEditorSheet: View {
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
                NameInput(name: $name)
                    .onSubmit { onSave(album, trim) }
            }.padding(20)
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

private struct NameInput: View {
    @FocusState private var nameFocused: Bool
    @Binding var name: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Name").font(.caption).foregroundStyle(.secondary)
            TextField(
                "e.g. Winter Vacation, Kittens",
                text: $name
            )
            .textFieldStyle(.roundedBorder)
            .focused($nameFocused)
            .task { nameFocused = true }
            .submitLabel(.done)
        }
    }
}
