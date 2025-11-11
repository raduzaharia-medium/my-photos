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

    private var tagStore: TagStore {
        TagStore(modelContainer: context.container)
    }
    private var albumStore: AlbumStore {
        AlbumStore(modelContainer: context.container)
    }
    private var personStore: PersonStore {
        PersonStore(modelContainer: context.container)
    }
    private var photoStore: PhotoStore {
        PhotoStore(modelContainer: context.container)
    }
    private var yearStore: YearStore {
        YearStore(modelContainer: context.container)
    }
    private var monthStore: MonthStore {
        MonthStore(modelContainer: context.container)
    }
    private var dayStore: DayStore {
        DayStore(modelContainer: context.container)
    }
    private var countryStore: CountryStore {
        CountryStore(modelContainer: context.container)
    }
    private var localityStore: LocalityStore {
        LocalityStore(modelContainer: context.container)
    }
    private var eventStore: EventStore {
        EventStore(modelContainer: context.container)
    }
    private var imageStore: ImageStore { ImageStore() }

    var body: some View {
        MainView()
            .animation(.default, value: presentationState.photoFilter)
            .animation(.default, value: presentationState.photoSelection)
            .animation(.default, value: presentationState.photoSource)
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
                context: context,
                presentationState: presentationState,
                notifier: notifier,
                fileImporter: fileImporter,
                modalPresenter: modalPresenter,
                photoStore: photoStore,
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
            .setupFilterHandlers(
                notifier: notifier,
                confirmer: confirmer,
                albumStore: albumStore,
                personStore: personStore,
                eventStore: eventStore,
                tagStore: tagStore
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
