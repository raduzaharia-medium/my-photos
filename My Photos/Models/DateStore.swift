import SwiftData
import SwiftUI

final class DateStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    @discardableResult
    func ensure(_ incoming: DateTakenDay?, _ month: DateTakenMonth?)
        -> DateTakenDay?
    {
        guard let incoming, let month else { return nil }

        let ensured = findOrCreateDay(in: month, dayValue: incoming.day)
        return ensured
    }

    @discardableResult
    func ensure(_ incoming: DateTakenMonth?, _ year: DateTakenYear?)
        -> DateTakenMonth?
    {
        guard let incoming, let year else { return nil }
        let ensuredMonth = findOrCreateMonth(
            in: year,
            monthValue: incoming.month
        )

        for day in incoming.days { ensure(day, ensuredMonth) }
        return ensuredMonth
    }

    @discardableResult
    func ensure(_ incoming: DateTakenYear?) -> DateTakenYear? {
        guard let incoming else { return nil }
        let ensuredYear = findOrCreateYear(incoming.year)

        for month in incoming.months { ensure(month, ensuredYear) }
        return ensuredYear
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
