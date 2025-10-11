import SwiftUI

struct DateTree: View {
    let years: [DateTakenYear]

    var body: some View {
        ForEach(years.sorted(by: { $0.year < $1.year })) { year in
            DisclosureGroup {
                ForEach(year.months.sorted(by: { $0.month < $1.month })) {
                    month in
                    DisclosureGroup {
                        ForEach(month.days.sorted(by: { $0.day < $1.day })) {
                            day in
                            SidebarRow(.dateDay(day))
                                .tag(SidebarItem.dateDay(day))
                        }
                    } label: {
                        SidebarRow(.dateMonth(month))
                            .tag(SidebarItem.dateMonth(month))
                    }
                }

            } label: {
                SidebarRow(.dateYear(year))
                    .tag(SidebarItem.dateYear(year))
            }
        }
    }
}
