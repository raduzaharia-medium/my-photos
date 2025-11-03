import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Environment(PresentationState.self) private var presentationState

    @StateObject private var modalPresenter = ModalService()
    @StateObject private var alerter = AlertService()
    @StateObject private var fileImporter = FileImportService()
    @StateObject private var notifier = NotificationService()
    @StateObject private var confirmer = ConfirmationService()

    private var tagStore: TagStore { TagStore(context: context) }
    private var albumStore: AlbumStore { AlbumStore(context: context) }
    private var personStore: PersonStore { PersonStore(context: context) }
    private var photoStore: PhotoStore { PhotoStore(context: context) }
    private var yearStore: YearStore { YearStore(context: context) }
    private var monthStore: MonthStore { MonthStore(context: context) }
    private var dayStore: DayStore { DayStore(context: context) }
    private var placeStore: PlaceStore { PlaceStore(context: context) }
    private var eventStore: EventStore { EventStore(context: context) }
    private var fileStore: FileStore { FileStore() }
    private var thumbnailStore: ThumbnailStore? { try? ThumbnailStore() }
    private var imageStore: ImageStore { ImageStore() }

    var body: some View {
        MainView()
            .animation(.default, value: presentationState.photoFilter)
            .animation(.default, value: presentationState.photoSelection)
            .animation(.default, value: presentationState.photoSource)
            .environment(\.thumbnailStore, thumbnailStore)
            .environment(\.imageStore, imageStore)
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
            .confirmationDialog(
                confirmer.title,
                isPresented: $confirmer.isVisible
            ) {
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
            .setupPhotoHandlers(
                presentationState: presentationState,
                notifier: notifier,
                fileImporter: fileImporter,
                modalPresenter: modalPresenter,
                photoStore: photoStore,
                fileStore: fileStore,
                tagStore: tagStore,
                yearStore: yearStore,
                monthStore: monthStore,
                dayStore: dayStore,
                placeStore: placeStore,
                albumStore: albumStore,
                personStore: personStore
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
    }
}

private struct MainView: View {
    var body: some View {
        #if os(macOS) || os(iPadOS)
            NavigationSplitView {
                SidebarView()
            } detail: {
                DetailView()
            }.navigationSplitViewStyle(.balanced)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 300)
        #else
            DetailView()
        #endif
    }
}
