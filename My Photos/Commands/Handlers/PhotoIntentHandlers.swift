import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

typealias NotificationOutput = NotificationCenter.Publisher.Output

extension View {
    func setupPhotoHandlers(
        context: ModelContext,
        presentationState: PresentationState,
        notifier: NotificationService,
        fileImporter: FileImportService,
        modalPresenter: ModalService,
        photoStore: PhotoStore,
    ) -> some View {
        let pickFolderPresenter = PickFolderPresenter(
            fileImporter: fileImporter,
            notifier: notifier
        )
        let pickTagPresenter = PickTagPresenter(modalPresenter: modalPresenter)
        let pickLocationPresenter = PickLocationPresenter(
            modalPresenter: modalPresenter
        )
        let importPhotosPresenter = ImportPhotosPresenter(
            modalPresenter: modalPresenter,
            notifier: notifier
        )
        let tagPhotosPresenter = TagPhotosPresenter(
            modalPresenter: modalPresenter,
            notifier: notifier
        )

        #if os(macOS)
            let importPhotos: (NotificationOutput) -> Void = { note in
                guard let folder = note.object as? URL else {
                    notifier.show("Could not import folder", .error)
                    return
                }

                importPhotosPresenter.show(folder)
            }
        #endif

        let tagPhotos: (NotificationOutput) -> Void = { note in
            guard let photoIDs = note.object as? [UUID] else { return }
            guard let tags = note.userInfo?["tags"] as? [SidebarItem] else {
                return
            }

            tagPhotosPresenter.show(photoIDs, tags: tags)
        }

        let showImporter: (NotificationOutput) -> Void = { _ in
            pickFolderPresenter.show()
        }
        let showTagger: (NotificationOutput) -> Void = { note in
            guard let photos = note.object as? [Photo] else { return }
            pickTagPresenter.show(photos)
        }
        let showDateChanger: (NotificationOutput) -> Void = { note in
            guard let photoIDs = note.object as? [UUID] else { return }
            let year = note.userInfo?["year"] as? Int
            let month = note.userInfo?["month"] as? Int
            let day = note.userInfo?["day"] as? Int

            withAnimation {
                modalPresenter.show(onDismiss: {}) {
                    DatePickerSheet(
                        photoIDs: photoIDs,
                        year: year,
                        month: month,
                        day: day
                    )
                }
            }
        }
        let showLocationChanger: (NotificationOutput) -> Void = { note in
            guard let photos = note.object as? [Photo] else { return }
            pickLocationPresenter.show(photos)
        }
        let clearSelection: (NotificationOutput) -> Void = { _ in
            withAnimation {
                presentationState.photoSelection.removeAll()
            }
        }
        let select: (NotificationOutput) -> Void = { note in
            guard let photo = note.object as? Photo else { return }

            withAnimation {
                presentationState.photoSelection = Set([photo])
            }
        }
        let selectMany: (NotificationOutput) -> Void = { note in
            guard let photos = note.object as? [Photo] else { return }

            withAnimation {
                presentationState.photoSelection = Set(photos)
            }
        }
        let enablePhotoSelectionMode: (NotificationOutput) -> Void = { _ in
            presentationState.photoSelectionMode = true
        }
        let disablePhotoSelectionMode: (NotificationOutput) -> Void = { _ in
            presentationState.photoSelectionMode = false
        }
        let togglePhotoSelectionMode: (NotificationOutput) -> Void = { _ in
            if presentationState.photoSelectionMode {
                presentationState.photoSelectionMode = false
            } else {
                presentationState.photoSelectionMode = true
            }
        }
        let toggleSelection: (NotificationOutput) -> Void = {
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
                NotificationCenter.default.publisher(
                    for: .requestChangeDatePhotos
                ),
                perform: showDateChanger
            )
            .onReceive(
                NotificationCenter.default.publisher(
                    for: .requestChangeLocationPhotos
                ),
                perform: showLocationChanger
            )
            #if os(macOS)
                .onReceive(
                    NotificationCenter.default.publisher(for: .importPhotos),
                    perform: importPhotos
                )
            #endif
            .onReceive(
                NotificationCenter.default.publisher(for: .tagPhotos),
                perform: tagPhotos
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
