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

    func getCountry(_ country: String) -> PlaceCountry? {
        let key = "\(country)"
        let descriptor = FetchDescriptor<PlaceCountry>(
            predicate: #Predicate { $0.key == key }
        )

        return (try? context.fetch(descriptor))?.first
    }

    func getLocality(_ country: PlaceCountry, _ locality: String)
        -> PlaceLocality?
    {
        let key = "\(country.key)-\(locality)"
        let descriptor = FetchDescriptor<PlaceLocality>(
            predicate: #Predicate { $0.key == key }
        )

        return (try? context.fetch(descriptor))?.first
    }

    func ensureCountry(_ country: String?) throws -> PlaceCountry? {
        guard let country else { return nil }
        let ensured = try findOrCreateCountry(country)

        return ensured
    }
    func ensureLocality(_ country: String?, _ locality: String?) throws
        -> PlaceLocality?
    {
        guard let country else { return nil }
        guard let locality else { return nil }

        let ensuredCountry = try findOrCreateCountry(country)
        let ensuredLocality = try findOrCreateLocality(ensuredCountry, locality)

        return ensuredLocality
    }

    private func findOrCreateCountry(_ country: String) throws -> PlaceCountry {
        if let existing = getCountry(country) { return existing }
        let newNode = PlaceCountry(country)

        context.insert(newNode)
        try context.save()
        return newNode
    }

    private func findOrCreateLocality(
        _ country: PlaceCountry,
        _ locality: String
    )
        throws -> PlaceLocality
    {
        if let existing = getLocality(country, locality) { return existing }
        let newNode = PlaceLocality(country, locality)

        context.insert(newNode)
        try context.save()
        return newNode
    }
}
