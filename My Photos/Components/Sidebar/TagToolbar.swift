import SwiftUI

struct NewTagButton: View {
    @EnvironmentObject var modalPresenter: ModalService
    @EnvironmentObject var notifier: NotificationService
    @EnvironmentObject var tagStore: TagStore
    
    var body: some View {
        Button {
            presentTagEditor(nil, modalPresenter: modalPresenter, notifier: notifier, tagStore: tagStore)
        } label: {
            Label("New Tag", systemImage: "plus")
        }
    }
}

struct TagToolbar: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem {
            NewTagButton()
        }
    }
}
