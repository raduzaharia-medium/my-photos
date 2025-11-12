import SwiftUI

struct LocationPickerSheet: View {
    @State private var selectedLocation: GeoCoordinate = GeoCoordinate(40, 40)

    let photos: [Photo]

    var onSave: ([Photo], GeoCoordinate) -> Void
    var onCancel: () -> Void

    init(
        photos: [Photo],

        onSave: @escaping ([Photo], GeoCoordinate) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.photos = photos

        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Map Input
                }
            }
            .padding(20)
            .frame(minWidth: 400, minHeight: 200)
            .navigationTitle("Change Location")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", role: .confirm) {
                        onSave(photos, selectedLocation)
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
        }.onAppear {
            for photo in photos {
                // TODO: see how to show existing dates
            }
        }
    }
}
