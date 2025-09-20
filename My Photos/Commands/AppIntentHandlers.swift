import Foundation
import SwiftUI

extension View {
    func setupSidebarHandlers(
        selection: Binding<Set<SidebarItem>>,
        filters: [Filter]
    ) -> some View {
        return self.onReceive(
            NotificationCenter.default.publisher(for: .resetTagSelection)
        ) { _ in
            selection.wrappedValue.removeAll()

            if let firstFilter = filters.first {
                selection.wrappedValue = [SidebarItem.filter(firstFilter)]
            }
        }
    }
}

extension View {
    func setupPhotoNavigationHandlers(index: Binding<Int>, count: Int)
        -> some View
    {
        return
            self
            .onReceive(
                NotificationCenter.default.publisher(
                    for: .navigateToPreviousPhoto
                )
            ) { _ in
                if index.wrappedValue > 0 {
                    index.wrappedValue = index.wrappedValue - 1
                }
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .navigateToNextPhoto)
            ) { _ in
                if index.wrappedValue + 1 < count {
                    index.wrappedValue = index.wrappedValue + 1
                }
            }
    }
}

extension View {
    func setupHandlers(
        modalPresenter: ModalService,
        notifier: NotificationService,
        fileImporter: FileImportService,
        alerter: AlertService,
        tagStore: TagStore
    ) -> some View {
        let editTagPresenter = EditTagPresenter(
            modalPresenter: modalPresenter,
            notifier: notifier,
            tagStore: tagStore
        )
        let importPhotosPresenter = ImportPhotosPresenter(
            fileImporter: fileImporter,
            notifier: notifier
        )
        let deleteTagPresenter = DeleteTagPresenter(
            alerter: alerter,
            notifier: notifier,
            tagStore: tagStore
        )

        return
            self
            .onReceive(
                NotificationCenter.default.publisher(for: .requestImportPhotos)
            ) { note in
                importPhotosPresenter.show()
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .requestCreateTag)
            ) { note in
                editTagPresenter.show(nil)
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .requestEditTag)
            ) { note in
                guard let tag = note.object as? Tag else { return }
                editTagPresenter.show(tag)
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .requestDeleteTag)
            ) { note in
                guard let tag = note.object as? Tag else { return }
                deleteTagPresenter.show(tag)
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .requestDeleteTags)
            ) { note in
                guard let tags = note.object as? [Tag] else { return }
                deleteTagPresenter.show(tags)
            }
    }
}
