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

    private var tagStore: TagStore { TagStore(context: context) }
    private var albumStore: AlbumStore { AlbumStore(context: context) }
    private var personStore: PersonStore { PersonStore(context: context) }
    private var photoStore: PhotoStore { PhotoStore(context: context) }
    private var dateStore: DateStore { DateStore(context: context) }
    private var placeStore: PlaceStore { PlaceStore(context: context) }
    private var eventStore: EventStore { EventStore(context: context) }
    private var fileStore: FileStore { FileStore() }

    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            DetailView()
        }
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
            alerter: alerter,
            tagStore: tagStore
        )
        .setupAlbumHandlers(
            modalPresenter: modalPresenter,
            notifier: notifier,
            alerter: alerter,
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
        .setupTagLoadingHandlers(
            presentationState: presentationState,
            tagPickerState: tagPickerState,
            dateStore: dateStore,
            notifier: notifier,
        )
        .setupPlaceLoadingHandlers(
            presentationState: presentationState,
            placeStore: placeStore
        )
        .setupPersonHandlers(
            modalPresenter: modalPresenter,
            notifier: notifier,
            alerter: alerter,
            personStore: personStore
        )
        .setupEventHandlers(
            modalPresenter: modalPresenter,
            notifier: notifier,
            alerter: alerter,
            eventStore: eventStore
        )
        .onAppear {
            AppIntents.loadPhotos()
        }
    }
}
