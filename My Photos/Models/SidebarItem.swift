import SwiftUI

enum SidebarItem: Hashable {
    case filter(Filter)
    case tag(Tag)

    var name: String {
        switch self {
        case .filter(let filter):
            return filter.name
        case .tag(let tag):
            return tag.name
        }
    }

    var icon: String {
        switch self {
        case .filter(let f): return f.icon
        case .tag(let t): return t.kind.icon
        }
    }
}

struct SidebarSelectionFocusedKey: FocusedValueKey {
    typealias Value = Binding<Set<SidebarItem>>
}

extension FocusedValues {
    var sidebarSelection: Binding<Set<SidebarItem>>? {
        get { self[SidebarSelectionFocusedKey.self] }
        set { self[SidebarSelectionFocusedKey.self] = newValue }
    }
}

extension Sequence where Element == SidebarItem {
    var allTags: [Tag] {
        compactMap {
            if case .tag(let t) = $0 { t } else { nil }
        }
    }

    var singleTag: Tag? {
        let tags = allTags
        return tags.count == 1 ? tags.first : nil
    }
    
    var hasFilter: Bool {
        contains { item in
            if case .filter = item { return true }
            return false
        }
    }
}
