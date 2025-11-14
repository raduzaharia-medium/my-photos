import SwiftUI

struct AlbumSetterSheet: View {
    @Environment(PresentationState.self) private var state
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var selectedAlbums: Set<Album>

    @State private var task: Task<Void, Never>? = nil
    @State private var total: Int = 0
    @State private var completed: Int = 0
    @State private var isSaving = false
    
    private var formattedExistingAlbums: String {
        let allAlbums = Set(state.photoSelection.flatMap(\.albums).sorted())
        let names = allAlbums.map(\.name)

        return names.joined(separator: " • ")
    }

    init(album: Album? = nil) {
        if let album {
            _selectedAlbums = State(initialValue: [album])
        } else {
            _selectedAlbums = State(initialValue: [])
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                AlbumInput(selection: $selectedAlbums)

                if formattedExistingAlbums.isEmpty {
                    Text("The selected photos will be added to these albums.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text(
                        "The selected photos will be added to these albums. Some selected photos are also part of other albums: \(formattedExistingAlbums)"
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }
            .allowsHitTesting(!isSaving)
            .padding(20)
            .frame(minWidth: 400, minHeight: 200)
            .navigationTitle("Add Photos to Albums")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        task?.cancel()
                        isSaving = false
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        task = Task { try? await doWork() }
                    } label: {
                        Text("Save")
                    }
                    .disabled(isSaving)
                }

                ToolbarItem(placement: .automatic) {
                    ProgressIndicator(
                        isSaving: $isSaving,
                        completed: $completed,
                        total: $total
                    )
                }
            }
        }
    }

    @MainActor
    private func doWork() async throws {
        let photoStore = PhotoStore(modelContainer: context.container)
        let photoIDs = state.photoSelection.map(\.id)
        let albumIDs = selectedAlbums.map(\.id)

        isSaving = true
        total = state.photoSelection.count
        completed = 0

        for id in photoIDs {
            if Task.isCancelled {
                isSaving = false
                dismiss()
            }

            try await photoStore.addAlbums(id, albumIDs)
            completed += 1
        }

        try await photoStore.save()

        PhotoIntents.toggleSelectionMode()
        isSaving = false
        dismiss()
    }
}
