import SwiftData
import SwiftUI

struct DatesSection: View {
    @Query(sort: \DateTakenYear.key) private var years: [DateTakenYear]

    var body: some View {
        Section("Dates") {
            ForEach(years) { year in
                DisclosureGroup {
                    DateSectionMonths(year: year)
                } label: {
                    SidebarRow(.dateYear(year)).tag(year)
                        .dropDestination(for: PhotoDragItem.self) { items, _ in
                            PhotoIntents.requestChangeDate(year: year.year)
                            return true
                        }
                }.listRowSeparator(.hidden)

            }
        }
    }
}

private struct DateSectionMonths: View {
    @Query private var months: [DateTakenMonth]
    let year: DateTakenYear

    init(year: DateTakenYear) {
        self.year = year
        self._months = Query(yearKey: year.key)
    }

    var body: some View {
        ForEach(months) { month in
            DisclosureGroup {
                DateSectionDays(month: month)
            } label: {
                SidebarRow(.dateMonth(month)).tag(month)
                    .dropDestination(for: PhotoDragItem.self) { items, _ in
                        PhotoIntents.requestChangeDate(
                            year: year.year,
                            month: month.month
                        )
                        return true
                    }
            }.listRowSeparator(.hidden)

        }
    }
}

private struct DateSectionDays: View {
    @Query private var days: [DateTakenDay]
    let month: DateTakenMonth

    init(month: DateTakenMonth) {
        self.month = month
        self._days = Query(monthKey: month.key)
    }

    var body: some View {
        ForEach(days) { day in
            SidebarRow(.dateDay(day)).tag(day)
                .dropDestination(for: PhotoDragItem.self) { items, _ in
                    PhotoIntents.requestChangeDate(
                        year: month.year.year,
                        month: month.month,
                        day: day.day
                    )
                    return true
                }
        }
    }
}

extension Query where Element == DateTakenMonth, Result == [DateTakenMonth] {
    fileprivate init(yearKey: String) {
        let filter = #Predicate<DateTakenMonth> { $0.year.key == yearKey }
        let sort = [SortDescriptor(\DateTakenMonth.key)]

        self.init(filter: filter, sort: sort)
    }
}

extension Query where Element == DateTakenDay, Result == [DateTakenDay] {
    init(monthKey: String) {
        let filter = #Predicate<DateTakenDay> { $0.month.key == monthKey }
        let sort = [SortDescriptor(\DateTakenDay.key)]

        self.init(filter: filter, sort: sort)
    }
}
