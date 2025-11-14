import SwiftUI

struct DateInput: View {
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
