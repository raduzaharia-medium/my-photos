import SwiftData
import SwiftUI

final class DateStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func insert(_ dateTakenYear: DateTakenYear) throws {
        context.insert(dateTakenYear)
        try context.save()
    }
    func insert(_ dateTakenYears: [DateTakenYear]) throws {
        for dateTakenYear in dateTakenYears {
            context.insert(dateTakenYear)
        }

        try context.save()
    }

    func getYears() -> [DateTakenYear] {
        let descriptor = FetchDescriptor<DateTakenYear>(
            sortBy: [SortDescriptor(\DateTakenYear.year, order: .reverse)]
        )

        if let fetched = try? context.fetch(descriptor) { return fetched }
        return []
    }
}
