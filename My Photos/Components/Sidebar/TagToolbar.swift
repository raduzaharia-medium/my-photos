import SwiftUI

struct NewTagButton: View {
    @EnvironmentObject var modalPresenter: ModalPresenterService
    @EnvironmentObject var notifier: NotificationService
    @EnvironmentObject var tagActions: TagActions
    
    var body: some View {
        Button {
            presentTagEditor(nil, modalPresenter: modalPresenter, notifier: notifier, tagActions: tagActions)
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
