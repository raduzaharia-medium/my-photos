import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension View {
    func setupPhotoHandlers(
        presentationState: PresentationState,
        notifier: NotificationService,
        fileImporter: FileImportService,
        modalPresenter: ModalService
    ) -> some View {
        let importPhotosPresenter = ImportPhotosPresenter(
            fileImporter: fileImporter,
            notifier: notifier
        )
        let pickTagPresenter = PickTagPresenter(modalPresenter: modalPresenter)

        let showImporter: (NotificationCenter.Publisher.Output) -> Void = { _ in
            importPhotosPresenter.show()
        }
        let showTagger: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let photos = note.object as? [Photo] else { return }
            pickTagPresenter.show(photos)
        }
        let clearSelection: (NotificationCenter.Publisher.Output) -> Void = {
            _ in
            presentationState.photoSelection.removeAll()
        }
        let select: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let photo = note.object as? Photo else { return }

            withAnimation {
                presentationState.photoSelection = Set([photo])
            }
        }
        let selectMany: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let photos = note.object as? [Photo] else { return }

            withAnimation {
                presentationState.photoSelection = Set(photos)
            }
        }
        let enablePhotoSelectionMode:
            (NotificationCenter.Publisher.Output) -> Void = { _ in
                presentationState.photoSelectionMode = true
            }
        let disablePhotoSelectionMode:
            (NotificationCenter.Publisher.Output) -> Void = { _ in
                presentationState.photoSelectionMode = false
            }
        let togglePhotoSelectionMode:
            (NotificationCenter.Publisher.Output) -> Void = { _ in
                if presentationState.photoSelectionMode {
                    presentationState.photoSelectionMode = false
                } else {
                    presentationState.photoSelectionMode = true
                }
            }
        let toggleSelection: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let photo = note.object as? Photo else { return }

            withAnimation {
                if presentationState.isSelected(photo) {
                    presentationState.photoSelection.remove(photo)
                } else {
                    presentationState.photoSelection.insert(photo)
                }
            }
        }

        return
            self.onReceive(
                NotificationCenter.default.publisher(for: .requestImportPhotos),
                perform: showImporter
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .requestTagPhotos),
                perform: showTagger
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .clearPhotoSelection),
                perform: clearSelection
            ).onReceive(
                NotificationCenter.default.publisher(
                    for: .togglePhotoSelection
                ),
                perform: toggleSelection
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .selectPhoto),
                perform: select
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .selectPhotos),
                perform: selectMany
            ).onReceive(
                NotificationCenter.default.publisher(
                    for: .enablePhotoSelectionMode
                ),
                perform: enablePhotoSelectionMode
            ).onReceive(
                NotificationCenter.default.publisher(
                    for: .disablePhotoSelectionMode
                ),
                perform: disablePhotoSelectionMode
            ).onReceive(
                NotificationCenter.default.publisher(
                    for: .togglePhotoSelectionMode
                ),
                perform: togglePhotoSelectionMode
            )
    }
}
