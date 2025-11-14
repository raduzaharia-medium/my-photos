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
    @State private var formattedExistingAlbums: String = ""

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
            .task {
                try? await loadExistingAlbums()
            }
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
                    ProgressIndication(
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

    @MainActor
    private func loadExistingAlbums() async throws {
        let allAlbums = Set(state.photoSelection.flatMap(\.albums).sorted())
        let names = allAlbums.map(\.name)

        self.formattedExistingAlbums = names.joined(separator: " • ")
    }
}

private struct DateInput: View {
    @FocusState private var focused: Bool
    @Binding var date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date Taken").font(.caption).foregroundStyle(.secondary)
            DatePicker(
                "",
                selection: $date,
                displayedComponents: .date
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .labelsHidden()
            .textFieldStyle(.roundedBorder)
            .focused($focused)
            .task { focused = true }
            .submitLabel(.done)
        }
    }
}

private struct ProgressIndication: View {
    @Binding var isSaving: Bool
    @Binding var completed: Int
    @Binding var total: Int

    var body: some View {
        if isSaving && completed < total {
            ProgressView(
                value: Double(completed),
                total: Double(max(total, 1))
            )
            .progressViewStyle(.circular)
            .controlSize(.small)
        } else if isSaving && completed == total {
            ProgressView()
                .progressViewStyle(.circular)
                .controlSize(.small)
        }
    }
}
