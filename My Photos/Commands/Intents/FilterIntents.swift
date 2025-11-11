import SwiftUI

extension Notification.Name {
    static let deleteFilters = Notification.Name("deleteFilters")
    static let requestDeleteFilters = Notification.Name("requestDeleteFilters")
}

enum FilterIntents {
    static func delete(_ filters: [SidebarItem]) {
        NotificationCenter.default.post(name: .deleteFilters, object: filters)
    }
    static func requestDelete(_ filters: [SidebarItem]) {
        NotificationCenter.default.post(
            name: .requestDeleteFilters,
            object: filters
        )
    }
}
