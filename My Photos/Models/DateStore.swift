import SwiftData
import SwiftUI

final class DateStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func ensureYear(_ dateTaken: Date?) -> DateTakenYear? {
        guard let dateTaken else { return nil }
        let year = Calendar.current.component(.year, from: dateTaken)
        let ensured = findOrCreateYear(year)

        return ensured
    }
    func ensureMonth(_ dateTaken: Date?) -> DateTakenMonth? {
        guard let dateTaken else { return nil }
        let year = Calendar.current.component(.year, from: dateTaken)
        let month = Calendar.current.component(.month, from: dateTaken)

        let ensuredYear = findOrCreateYear(year)
        let ensuredMonth = findOrCreateMonth(in: ensuredYear, monthValue: month)

        return ensuredMonth
    }
    func ensureDay(_ dateTaken: Date?) -> DateTakenDay? {
        guard let dateTaken else { return nil }
        let year = Calendar.current.component(.year, from: dateTaken)
        let month = Calendar.current.component(.month, from: dateTaken)
        let day = Calendar.current.component(.day, from: dateTaken)

        let ensuredYear = findOrCreateYear(year)
        let ensuredMonth = findOrCreateMonth(in: ensuredYear, monthValue: month)
        let ensuredDay = findOrCreateDay(in: ensuredMonth, dayValue: day)
        
        return ensuredDay
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

    private func findOrCreateYear(_ yearValue: Int) -> DateTakenYear {
        if let existing = getYear(yearValue) { return existing }
        let newNode = DateTakenYear(yearValue)

        context.insert(newNode)
        return newNode
    }

    private func findOrCreateMonth(in year: DateTakenYear, monthValue: Int)
        -> DateTakenMonth
    {
        if let existing = getMonth(year, monthValue) { return existing }
        let newNode = DateTakenMonth(year, monthValue)

        context.insert(newNode)
        return newNode
    }

    private func findOrCreateDay(in month: DateTakenMonth, dayValue: Int)
        -> DateTakenDay
    {
        if let existing = getDay(month, dayValue) { return existing }
        let newNode = DateTakenDay(month, dayValue)

        context.insert(newNode)
        return newNode
    }

    func getYear(_ year: Int) -> DateTakenYear? {
        let years = getYears().filter { $0.year == year }
        return years.first
    }
    func getMonth(_ year: DateTakenYear, _ month: Int) -> DateTakenMonth? {
        return year.months.first(where: { $0.month == month })
    }
    func getDay(_ month: DateTakenMonth, _ day: Int) -> DateTakenDay? {
        return month.days.first(where: { $0.day == day })
    }

    func getYears() -> [DateTakenYear] {
        let descriptor = FetchDescriptor<DateTakenYear>(
            sortBy: [SortDescriptor(\DateTakenYear.year, order: .reverse)]
        )

        if let fetched = try? context.fetch(descriptor) { return fetched }
        return []
    }
}
