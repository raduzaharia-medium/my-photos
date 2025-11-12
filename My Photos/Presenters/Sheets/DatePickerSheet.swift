import SwiftUI

struct DatePickerSheet: View {
    @State private var selectedDate: Date = Date()

    let photos: [Photo]

    var onSave: ([Photo], Date) -> Void
    var onCancel: () -> Void

    init(
        photos: [Photo],

        onSave: @escaping ([Photo], Date) -> Void,
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
                    // Date Input
                }
            }
            .padding(20)
            .frame(minWidth: 400, minHeight: 200)
            .navigationTitle("Change Date Taken")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", role: .confirm) {
                        onSave(photos, selectedDate)
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
