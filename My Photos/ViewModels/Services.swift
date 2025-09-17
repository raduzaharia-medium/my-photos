import SwiftUI

@MainActor
final class Services: ObservableObject {
    @Published var notifier: Notifier
    @Published var alerter: Alerter
    @Published var fileImporter: FileImporter
    @Published var modalPresenter: ModalPresenter

    init(
        notifier: Notifier,
        alerter: Alerter,
        fileImporter: FileImporter,
        modalPresenter: ModalPresenter
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
