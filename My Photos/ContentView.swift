import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Environment(PresentationState.self) private var presentationState
    @Environment(TagPickerState.self) private var tagPickerState

    @StateObject private var modalPresenter = ModalService()
    @StateObject private var alerter = AlertService()
    @StateObject private var fileImporter = FileImportService()
    @StateObject private var notifier = NotificationService()
    @StateObject private var confirmer = ConfirmationService()

    private var tagStore: TagStore { TagStore(context: context) }
    private var albumStore: AlbumStore { AlbumStore(context: context) }
    private var personStore: PersonStore { PersonStore(context: context) }
    private var photoStore: PhotoStore { PhotoStore(context: context) }
    private var dateStore: DateStore { DateStore(context: context) }
    private var placeStore: PlaceStore { PlaceStore(context: context) }
    private var eventStore: EventStore { EventStore(context: context) }
    private var fileStore: FileStore { FileStore() }

    var body: some View {
        MainView()
            .notification(
                isPresented: $notifier.isVisible,
                message: notifier.message,
                style: notifier.style
            )
            .sheet(
                item: $modalPresenter.item,
                onDismiss: {
                    modalPresenter.item?.onDismiss?()
                }
            ) { item in
                item.content
            }
            .alert(
                alerter.title,
                isPresented: $alerter.isVisible
            ) {
                Button(alerter.actionLabel, role: .destructive) {
                    alerter.action()
                }
                Button(alerter.cancelLabel, role: .cancel) {
                    alerter.cancel()
                }
            } message: {
                Text(alerter.message)
            }
            .confirmationDialog(confirmer.title, isPresented: $confirmer.isVisible) {
                Button(confirmer.actionLabel, role: .destructive) {
                    confirmer.action()
                }
            } message: {
                Text(confirmer.message)
            }
            .fileImporter(
                isPresented: $fileImporter.isVisible,
                allowedContentTypes: fileImporter.allowedContentTypes,
                allowsMultipleSelection: fileImporter.multipleSelection,
                onCompletion: fileImporter.action
            )
            .setupHandlers(
                modalPresenter: modalPresenter,
                notifier: notifier,
                fileImporter: fileImporter,
                alerter: alerter,
            )
            .setupTagHandlers(
                modalPresenter: modalPresenter,
                notifier: notifier,
                confirmer: confirmer,
                tagStore: tagStore
            )
            .setupAlbumHandlers(
                modalPresenter: modalPresenter,
                notifier: notifier,
                confirmer: confirmer,
                albumStore: albumStore
            )
            .setupPhotoLoadingHandlers(
                presentationState: presentationState,
                notifier: notifier,
                photoStore: photoStore,
                tagStore: tagStore,
                fileStore: fileStore,
                dateStore: dateStore,
                placeStore: placeStore
            )
            .setupPersonHandlers(
                modalPresenter: modalPresenter,
                notifier: notifier,
                confirmer: confirmer,
                personStore: personStore
            )
            .setupEventHandlers(
                modalPresenter: modalPresenter,
                notifier: notifier,
                confirmer: confirmer,
                eventStore: eventStore
            )
            .setupPresentationModeHandlers(presentationState: presentationState)
            .setupPhotoSelectionHandlers(presentationState: presentationState)
    }
}

private struct MainView: View {
    var body: some View {
        #if os(macOS)
            NavigationSplitView {
                SidebarView()
            } detail: {
                DetailView()
            }.navigationSplitViewStyle(.balanced)
        #else
            DetailView()
        #endif
    }
}
