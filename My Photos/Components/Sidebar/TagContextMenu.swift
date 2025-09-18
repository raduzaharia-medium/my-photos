import SwiftUI

struct TagContextMenu: View {
    @EnvironmentObject private var modalPresenter: ModalService
    @EnvironmentObject private var alerter: AlertService
    @EnvironmentObject private var notifier: NotificationService
    @EnvironmentObject private var tagActions: TagActions
    @EnvironmentObject private var tagSelectionModel: TagSelectionModel

    var selection: Set<SidebarItem>

    init(_ selection: Set<SidebarItem>) {
        self.selection = selection
    }

    var body: some View {
        if let tag = singleTag(from: selection) {
            Button {
                presentTagEditor(
                    tag,
                    modalPresenter: modalPresenter,
                    notifier: notifier,
                    tagActions: tagActions
                )
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button(role: .destructive) {
                presentTagRemover(
                    tag,
                    alerter: alerter,
                    notifier: notifier,
                    tagActions: tagActions,
                    tagSelectionModel: tagSelectionModel
                )
            } label: {
                Label("Delete", systemImage: "trash")
            }
        } else if let tags = allTags(from: selection), !tags.isEmpty {
            Button(role: .destructive) {
                presentTagsRemover(
                    tags,
                    alerter: alerter,
                    notifier: notifier,
                    tagActions: tagActions,
                    tagSelectionModel: tagSelectionModel
                )
            } label: {
                Label("Delete \(tags.count) Tags", systemImage: "trash")
            }
        }
    }

    private func singleTag(from items: Set<SidebarItem>) -> Tag? {
        guard items.count == 1, case .tag(let t) = items.first else {
            return nil
        }

        return t
    }

    private func allTags(from items: Set<SidebarItem>) -> [Tag]? {
        let tags: [Tag] = items.compactMap { item in
            if case .tag(let t) = item { return t }
            return nil
        }
        return tags
    }
}
