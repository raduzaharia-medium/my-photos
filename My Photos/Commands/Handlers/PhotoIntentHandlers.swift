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
        let showDateChanger: (NotificationOutput) -> Void = { note in
            let year = note.userInfo?["year"] as? Int
            let month = note.userInfo?["month"] as? Int
            let day = note.userInfo?["day"] as? Int

            modalPresenter.show(onDismiss: {}) {
                DateSetterSheet(year: year, month: month, day: day)
            }
        }
        let showLocationChanger: (NotificationOutput) -> Void = { note in
            let country = note.userInfo?["country"] as? PlaceCountry
            let locality = note.userInfo?["locality"] as? PlaceLocality

            modalPresenter.show(onDismiss: {}) {
                LocationSetterSheet(country: country, locality: locality)
            }
        }
        let showAlbumChanger: (NotificationOutput) -> Void = { note in
            let album = note.object as? Album

            modalPresenter.show(onDismiss: {}) {
                AlbumSetterSheet(album: album)
            }
        }
        let showPersonChanger: (NotificationOutput) -> Void = { note in
            let person = note.object as? Person

            modalPresenter.show(onDismiss: {}) {
                PersonSetterSheet(person: person)
            }
        }
        let showEventChanger: (NotificationOutput) -> Void = { note in
            let event = note.object as? Event

            modalPresenter.show(onDismiss: {}) {
                EventSetterSheet(event: event)
            }
        }
        let showTagChanger: (NotificationOutput) -> Void = { note in
            let tag = note.object as? Tag

            modalPresenter.show(onDismiss: {}) { TagSetterSheet(tag: tag) }
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
                NotificationCenter.default.publisher(
                    for: .requestChangeDatePhotos
                ),
                perform: showDateChanger
            )
            .onReceive(
                NotificationCenter.default.publisher(
                    for: .requestChangeAlbumPhotos
                ),
                perform: showAlbumChanger
            )
            .onReceive(
                NotificationCenter.default.publisher(
                    for: .requestChangePersonPhotos
                ),
                perform: showPersonChanger
            )
            .onReceive(
                NotificationCenter.default.publisher(
                    for: .requestChangeEventPhotos
                ),
                perform: showEventChanger
            )
            .onReceive(
                NotificationCenter.default.publisher(
                    for: .requestChangeLocationPhotos
                ),
                perform: showLocationChanger
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .requestChangeTagPhotos),
                perform: showTagChanger
            )
            #if os(macOS)
                .onReceive(
                    NotificationCenter.default.publisher(for: .importPhotos),
                    perform: importPhotos
                )
            #endif
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
