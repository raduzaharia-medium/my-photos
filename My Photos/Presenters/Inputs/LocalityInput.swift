import SwiftData
import SwiftUI

struct LocalityInput: View {
    @Query(sort: [SortDescriptor(\PlaceLocality.key)]) private var localities:
        [PlaceLocality]
    @Binding var selection: PlaceLocality?

    init(locality: Binding<PlaceLocality?> = .constant(nil)) {
        self._selection = locality
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Locality")
                .font(.caption)
                .foregroundStyle(.secondary)

            Picker("", selection: $selection) {
                Text("Select…").tag(Optional<PlaceLocality>.none)

                ForEach(localities) { locality in
                    Label {
                        Text(locality.locality)
                    } icon: {
                        Image(systemName: PlaceCountry.icon)
                    }
                    .tag(Optional(locality))
                }
            }
            .labelsHidden()
            .frame(maxWidth: .infinity, alignment: .leading)
            .pickerStyle(.menu)
        }
    }
}
