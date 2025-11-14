import SwiftUI

struct PhotoSummarySheet: View {
    @Environment(PresentationState.self) private var state
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var selectedAlbums: Set<Album> = []
    @State private var selectedPeople: Set<Person> = []
    @State private var selectedEvents: Set<Event> = []
    @State private var selectedTags: Set<Tag> = []

    @State private var task: Task<Void, Never>? = nil
    @State private var total: Int = 0
    @State private var completed: Int = 0
    @State private var isSaving = false

    private var allItems: [SidebarItem] {
        let albumItems = Set(selectedAlbums.map { SidebarItem.album($0) })
        let peopleItems = Set(selectedPeople.map { SidebarItem.person($0) })
        let eventItems = Set(selectedEvents.map { SidebarItem.event($0) })
        let tagItems = Set(selectedTags.map { SidebarItem.tag($0) })

        return Array(
            albumItems.union(peopleItems).union(eventItems).union(tagItems)
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    AlbumInput(selection: $selectedAlbums)
                    PersonInput(selection: $selectedPeople)
                    EventInput(selection: $selectedEvents)
                    TagInput(selection: $selectedTags)
                }
            }
            .padding(20)
            .frame(minWidth: 400, minHeight: 200)
            .navigationTitle("Assign Tags")
            .onAppear {
                selectedAlbums = Set(state.photoSelection.flatMap(\.albums))
                selectedPeople = Set(state.photoSelection.flatMap(\.people))
                selectedEvents = Set(state.photoSelection.flatMap(\.events))
                selectedTags = Set(state.photoSelection.flatMap(\.tags))
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
                    Button("Save", role: .confirm) {
                        guard !allItems.isEmpty else { return }
                        task = Task { try? await doWork() }
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(allItems.isEmpty)
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
        let photoIDs = Set(state.photoSelection.map(\.id))
        
        isSaving = true
        total = state.photoSelection.count
        completed = 0

        for id in photoIDs {
            if Task.isCancelled {
                isSaving = false
                dismiss()
            }

            try await photoStore.addAlbums(id, selectedAlbums.compactMap(\.id))
            try await photoStore.addPeople(id, selectedPeople.compactMap(\.id))
            try await photoStore.addEvents(id, selectedEvents.compactMap(\.id))
            try await photoStore.addTags(id, selectedTags.compactMap(\.id))
            
            completed += 1
        }

        try await photoStore.save()

        PhotoIntents.toggleSelectionMode()
        isSaving = false
        dismiss()
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
