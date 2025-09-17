import SwiftUI

struct TagContextMenu: View {
    @EnvironmentObject var modalPresenter: ModalPresenterService
    @EnvironmentObject var alerter: AlertService
    @EnvironmentObject var tagActions: TagActions
    
    var selection: Set<SidebarItem>

    init(_ selection: Set<SidebarItem>) {
        self.selection = selection
    }

    var body: some View {
        if let tag = singleTag(from: selection) {
            Button {
                modalPresenter.show(onDismiss: {}) {
                    TagEditorSheet(
                        tag,
                        onSave: { original, name, kind in
                            withAnimation {
                                tagActions.upsert(original?.id, name: name, kind: kind)
                                modalPresenter.dismiss()
                            }
                        },
                        onCancel: { modalPresenter.dismiss() }
                    )
                }
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button(role: .destructive) {
                alerter.show(
                    "Delete \(tag.name)?",
                    "Are you sure you want to delete this tag?",
                    actionLabel: "Delete",
                    onAction: {
                        withAnimation {
                            tagActions.delete(tag.id)
                        }
                    }
                )

            } label: {
                Label("Delete", systemImage: "trash")
            }
        } else if let tags = allTags(from: selection), !tags.isEmpty {
            Button(role: .destructive) {
                alerter.show(
                    "Delete \(tags.count) Tags?",
                    "Are you sure you want to delete these tags?",
                    actionLabel: "Delete",
                    onAction: {
                        withAnimation {
                            tagActions.delete(tags.map(\.id))
                        }
                    }
                )
            } label: {
                Label("Delete \(tags.count) Tags", systemImage: "trash")
            }
        }
    }

    private func singleTag(from items: Set<SidebarItem>) -> Tag? {
        guard items.count == 1, case let .tag(t) = items.first else {
            return nil
        }

        return t
    }

    private func allTags(from items: Set<SidebarItem>) -> [Tag]? {
        let tags: [Tag] = items.compactMap { item in
            if case let .tag(t) = item { return t }
            return nil
        }
        return tags
    }
}

