import SwiftUI

struct DateTree: View {
    let years: [DateTakenYear]

    var body: some View {
        ForEach(years.sorted(by: { $0.year < $1.year })) { year in
            DisclosureGroup {
                ForEach(year.months.sorted(by: { $0.month < $1.month })) { month in
                    DisclosureGroup {
                        ForEach(month.days.sorted(by: { $0.day < $1.day })) { day in
                            SidebarRow(.dateDay(year.year, month.month, day.day))
                                .tag(SidebarItem.dateDay(year.year, month.month, day.day))
                        }
                    } label: {
                        SidebarRow(.dateMonth(year.year, month.month))
                            .tag(SidebarItem.dateMonth(year.year, month.month))
                    }
                }
            } label: {
                SidebarRow(.dateYear(year.year))
                    .tag(SidebarItem.dateYear(year.year))
            }
        }
    }
}
