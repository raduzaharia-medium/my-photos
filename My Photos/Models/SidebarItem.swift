import SwiftUI

enum SidebarItem: Hashable {
    case filter(Filter)
    case tag(Tag)
    case dateYear(Int)
    case dateMonth(Int, Int)
    case dateDay(Int, Int, Int)

    var name: String {
        switch self {
        case .filter(let filter):
            return filter.name
        case .tag(let tag):
            return tag.name
        case .dateYear(let year):
            return "\(year)"
        case .dateMonth(_, let month):
            return monthName(month)
        case .dateDay(_, _, let day):
            return "\(day)"
        }
    }

    var icon: String {
        switch self {
        case .filter(let filter): return filter.icon
        case .tag(let tag): return tag.kind.icon
        case .dateYear(_): return "calendar"
        case .dateMonth(_, _): return "calendar"
        case .dateDay(_, _, _): return "calendar"
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
