import SwiftUI

@MainActor
final class Services: ObservableObject {
    @Published var notifier: NotificationService
    @Published var alerter: AlertService
    @Published var fileImporter: FileImportService
    @Published var modalPresenter: ModalPresenterService

    init(
        notifier: NotificationService,
        alerter: AlertService,
        fileImporter: FileImportService,
        modalPresenter: ModalPresenterService
    ) {
        self.notifier = notifier
        self.alerter = alerter
        self.fileImporter = fileImporter
        self.modalPresenter = modalPresenter
    }
    init() {
        self.notifier = NotificationService()
        self.alerter = AlertService()
        self.fileImporter = FileImportService()
        self.modalPresenter = ModalPresenterService()
    }
}
