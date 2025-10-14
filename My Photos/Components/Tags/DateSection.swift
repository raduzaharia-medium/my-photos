import SwiftData
import SwiftUI

struct DateSection: View {
    @Query(sort: \DateTakenYear.key) private var years: [DateTakenYear]

    var body: some View {
        Section("Dates") {
            ForEach(years) { year in
                DisclosureGroup {
                    DateSectionMonths(year: year)
                } label: {
                    SidebarRow(.dateYear(year)).tag(year)
                }
            }
        }
    }
}

struct DateSectionMonths: View {
    @Query private var months: [DateTakenMonth]
    let year: DateTakenYear

    init(year: DateTakenYear) {
        self.year = year

        let yearKey = year.key
        let predicate = #Predicate<DateTakenMonth> { month in
            month.year.key == yearKey
        }

        self._months = Query(
            filter: predicate,
            sort: [SortDescriptor(\DateTakenMonth.key)]
        )
    }

    var body: some View {
        ForEach(months) { month in
            DisclosureGroup {
                DateSectionDays(month: month)
            } label: {
                SidebarRow(.dateMonth(month)).tag(month)
            }
        }
    }
}

struct DateSectionDays: View {
    @Query private var days: [DateTakenDay]
    let month: DateTakenMonth

    init(month: DateTakenMonth) {
        self.month = month

        let monthKey = month.key
        let predicate = #Predicate<DateTakenDay> { day in
            day.month.key == monthKey
        }

        self._days = Query(
            filter: predicate,
            sort: [SortDescriptor(\DateTakenDay.key)]
        )
    }

    var body: some View {
        ForEach(days) {
            day in
            SidebarRow(.dateDay(day)).tag(day)
        }
    }
}
