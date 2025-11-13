import SwiftUI

struct AlbumEditorSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name: String

    let album: Album?

    var title: String { album == nil ? "New Album" : "Edit Album" }
    var trim: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    var canSave: Bool { !trim.isEmpty }

    init(_ album: Album? = nil) {
        self.album = album
        self._name = State(initialValue: album?.name ?? "")
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                NameInput(name: $name).onSubmit { Task { try? await doWork() } }
                Spacer(minLength: 0)
            }.padding(20)
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save", role: .confirm) {
                            Task { try? await doWork() }
                        }.keyboardShortcut(.defaultAction)
                            .disabled(!canSave)
                    }
                }
                .interactiveDismissDisabled(!canSave)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    @MainActor
    private func doWork() async throws {
        let albumStore = AlbumStore(modelContainer: context.container)

        if let album {
            try await albumStore.update(album.id, trim)
        } else {
            try await albumStore.create(trim)
        }

        dismiss()
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
