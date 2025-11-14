import SwiftData
import SwiftUI

struct CountryInput: View {
    @Query(sort: [SortDescriptor(\PlaceCountry.key)]) private var countries:
        [PlaceCountry]
    @Binding var selection: PlaceCountry?

    init(country: Binding<PlaceCountry?> = .constant(nil)) {
        self._selection = country
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Country")
                .font(.caption)
                .foregroundStyle(.secondary)

            Picker("", selection: $selection) {
                Text("Select…").tag(Optional<PlaceCountry>.none)

                ForEach(countries) { country in
                    Label {
                        Text(country.country)
                    } icon: {
                        Image(systemName: PlaceCountry.icon)
                    }
                    .tag(Optional(country))
                }
            }
            .labelsHidden()
            .frame(maxWidth: .infinity, alignment: .leading)
            .pickerStyle(.menu)
        }
    }
}
