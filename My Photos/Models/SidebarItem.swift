import SwiftUI

enum SidebarItem: Hashable {
    case filter(Filter)
    case tag(Tag)
    case dateYear(DateTakenYear)
    case dateMonth(DateTakenMonth)
    case dateDay(DateTakenDay)

    var name: String {
        switch self {
        case .filter(let filter):
            return filter.name
        case .tag(let tag):
            return tag.name
        case .dateYear(let date):
            return "\(date.year)"
        case .dateMonth(let date):
            return monthName(date.month)
        case .dateDay(let date):
            return "\(date.day)"
        }
    }

    var icon: String {
        switch self {
        case .filter(let filter): return filter.icon
        case .tag(let tag): return tag.kind.icon
        case .dateYear(_): return "calendar"
        case .dateMonth(_): return "calendar"
        case .dateDay(_): return "calendar"
        }
    }
    
    private func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()

        formatter.locale = Locale.current

        return formatter.monthSymbols[max(0, min(11, month - 1))]
    }
}

extension Set where Element == SidebarItem {
    var selectedTags: [Tag] {
        compactMap {
            if case .tag(let t) = $0 { t } else { nil }
        }
    }
    var selectedFilters: [Filter] {
        compactMap {
            if case .filter(let t) = $0 { t } else { nil }
        }
    }

    var canEditOrDeleteSelection: Bool {
        selectedTags.count > 0 && selectedFilters.count == 0
    }
    var canEditSelection: Bool {
        selectedTags.count == 1 && selectedFilters.count == 0
    }
    var canDeleteSelection: Bool {
        selectedTags.count == 1 && selectedFilters.count == 0
    }
    var canDeleteManySelection: Bool {
        selectedTags.count > 1 && selectedFilters.count == 0
    }
}
