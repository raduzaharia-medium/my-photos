import SwiftUI

struct LocationSetterSheet: View {
    @Environment(PresentationState.self) private var state
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var selectedCountry: PlaceCountry?
    @State private var selectedLocality: PlaceLocality?

    @State private var task: Task<Void, Never>? = nil
    @State private var total: Int = 0
    @State private var completed: Int = 0
    @State private var isSaving = false

    private var formattedPhotoCountries: String {
        let countries = state.photoSelection.compactMap(\.country)
        let formatted = Set(countries).sorted().map(\.name)
        
        return formatted.joined(separator: " • ")
    }
    private var formattedPhotoLocalities: String {
        let localities = state.photoSelection.compactMap(\.locality)
        let formatted = Set(localities).sorted().map(\.name)
        
        return formatted.joined(separator: " • ")
    }

    init(country: PlaceCountry? = nil, locality: PlaceLocality? = nil) {
        if let country {
            self._selectedCountry = State(initialValue: country)
        }

        if let locality {
            self._selectedCountry = State(initialValue: locality.country) 
            self._selectedLocality = State(initialValue: locality)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                CountryInput(country: $selectedCountry)
                Text("Existing countries in selection: \(formattedPhotoCountries)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                LocalityInput(locality: $selectedLocality)
                Text("Existing localities in selection: \(formattedPhotoLocalities)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)
            }
            .allowsHitTesting(!isSaving)
            .padding(20)
            .frame(minWidth: 400, minHeight: 200)
            .navigationTitle("Change Place")
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

        isSaving = true
        total = photoIDs.count
        completed = 0

        for id in photoIDs {
            if Task.isCancelled {
                isSaving = false
                dismiss()
            }

            if let selectedCountry {
                try await photoStore.setCountry(id, selectedCountry.id)
            }
            if let selectedLocality {
                try await photoStore.setLocality(id, selectedLocality.id)
            }
            
            completed += 1
        }

        try await photoStore.save()

        PhotoIntents.toggleSelectionMode()
        isSaving = false
        dismiss()
    }
}
