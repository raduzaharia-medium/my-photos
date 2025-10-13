import SwiftData
import SwiftUI

final class PlaceStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func getCountries() -> [PlaceCountry] {
        let descriptor = FetchDescriptor<PlaceCountry>(
            sortBy: [SortDescriptor(\PlaceCountry.key, order: .reverse)]
        )

        if let fetched = try? context.fetch(descriptor) { return fetched }
        return []
    }
}
