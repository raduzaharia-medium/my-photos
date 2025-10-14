import SwiftUI

struct PlaceTree: View {
    let countries: [CountryViewModel]
    
    var body: some View {
        ForEach(countries.sorted(by: { $0.key < $1.key })) { country in
            DisclosureGroup {
                ForEach(country.localities.sorted(by: { $0.key < $1.key })) {
                    locality in
                    SidebarRow(.placeLocality(locality)).tag(locality)
                }

            } label: {
                SidebarRow(.placeCountry(country)).tag(country)
            }
        }
    }
}
