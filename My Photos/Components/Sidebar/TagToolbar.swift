import SwiftUI

struct NewTagButton: View {
    @EnvironmentObject var modalPresenter: ModalPresenterService
    @EnvironmentObject var tagActions: TagActions
 
    var body: some View {
        Button {
            modalPresenter.show(onDismiss: {}) {
                TagEditorSheet(
                    nil,
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
