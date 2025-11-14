import SwiftData
import SwiftUI

struct PlacesSection: View {
    @Query(sort: \PlaceCountry.key) private var countries: [PlaceCountry]

    var body: some View {
        Section("Places") {
            ForEach(countries) { country in
                DisclosureGroup {
                    DateSectionLocalities(country: country)
                } label: {
                    SidebarRow(.placeCountry(country)).tag(country)
                        .dropDestination(for: PhotoDragItem.self) { items, _ in                           
                            PhotoIntents.requestChangeLocation(country: country)
                            return true
                        }
                }.listRowSeparator(.hidden)

            }
        }
    }
}

private struct DateSectionLocalities: View {
    @Query private var localities: [PlaceLocality]
    let country: PlaceCountry

    init(country: PlaceCountry) {
        self.country = country
        self._localities = Query(countryKey: country.key)
    }

    var body: some View {
        ForEach(localities) { locality in
            SidebarRow(.placeLocality(locality)).tag(locality)
                .dropDestination(for: PhotoDragItem.self) { items, _ in
                    PhotoIntents.requestChangeLocation(locality: locality)
                    return true
                }
        }
    }
}

extension Query where Element == PlaceLocality, Result == [PlaceLocality] {
    fileprivate init(countryKey: String) {
        let filter = #Predicate<PlaceLocality> { $0.country.key == countryKey }
        let sort = [SortDescriptor(\PlaceLocality.key)]

        self.init(filter: filter, sort: sort)
    }
}
