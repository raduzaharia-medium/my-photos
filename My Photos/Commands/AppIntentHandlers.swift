import Foundation
import SwiftUI

extension View {
    func setupTagLoadingHandlers(
        presentationState: PresentationState,
        notifier: NotificationService,
        tagStore: TagStore
    ) -> some View {
        return self.onReceive(
            NotificationCenter.default.publisher(for: .loadTags)
        ) { _ in
            let tags = tagStore.getTags()
            presentationState.tags = tags
        }.onReceive(
            NotificationCenter.default.publisher(for: .editTag)
        ) { note in
            guard let tag = note.object as? Tag else { return }
            guard let name = note.userInfo?["name"] as? String else { return }
            guard let kind = note.userInfo?["kind"] as? TagKind else { return }

            do {
                try tagStore.update(
                    tag.persistentModelID,
                    name: name,
                    kind: kind
                )
                notifier.show("Tag updated", .success)
            } catch {
                notifier.show("Could not update tag", .error)
            }
        }
    }

    func setupPhotoLoadingHandlers(
        presentationState: PresentationState,
        notifier: NotificationService,
        photoStore: PhotoStore
    ) -> some View {
        return self.onReceive(
            NotificationCenter.default.publisher(for: .loadPhotos)
        ) { _ in
            let photos = photoStore.getPhotos()
            presentationState.photos = photos
        }.onReceive(
            NotificationCenter.default.publisher(for: .resetPhotoFilter)
        ) { _ in
            presentationState.photoFilter.removeAll()
            presentationState.photoFilter.insert(SidebarItem.filter(.all))

            let photos = photoStore.getPhotos()
            presentationState.photos = photos
        }.onReceive(
            NotificationCenter.default.publisher(for: .updatePhotoFilter)
        ) { note in
            guard let photoFilters = note.object as? Set<SidebarItem> else {
                return
            }

            presentationState.photoFilter.removeAll()
            presentationState.photoFilter.formUnion(photoFilters)

            let photos = photoStore.getPhotos(photoFilters)
            presentationState.photos = photos
        }.onReceive(
            NotificationCenter.default.publisher(for: .tagSelectedPhotos)
        ) { note in
            guard let tag = note.object as? Tag else { return }

            do {
                try photoStore.tagPhotos(presentationState.selectedPhotos, tag)
            } catch {
                notifier.show("Failed to tag photos", .error)
            }
        }
    }

    func setupPhotoSelectionHandlers(presentationState: PresentationState)
        -> some View
    {
        return
            self
            .onReceive(
                NotificationCenter.default.publisher(for: .selectPhoto)
            ) { note in
                guard let photo = note.object as? Photo else { return }
                presentationState.selectedPhotos.insert(photo)
            }.onReceive(
                NotificationCenter.default.publisher(for: .deselectPhoto)
            ) { note in
                guard let photo = note.object as? Photo else { return }
                presentationState.selectedPhotos.remove(photo)
            }.onReceive(
                NotificationCenter.default.publisher(for: .togglePhotoSelection)
            ) { note in
                guard let photo = note.object as? Photo else { return }

                if presentationState.selectedPhotos.contains(photo) {
                    presentationState.selectedPhotos.remove(photo)
                } else {
                    presentationState.selectedPhotos.insert(photo)
                }
            }
    }

    func setupPresentationModeHandlers(presentationState: PresentationState)
        -> some View
    {
        return self.onReceive(
            NotificationCenter.default.publisher(for: .togglePresentationMode)
        ) { _ in
            if presentationState.presentationMode == .grid {
                presentationState.presentationMode = .map
            } else {
                presentationState.presentationMode = .grid
            }
        }.onReceive(
            NotificationCenter.default.publisher(for: .toggleSelectionMode)
        ) { _ in
            presentationState.isSelecting.toggle()
            presentationState.showOnlySelected = false
            presentationState.selectedPhotos.removeAll()
        }.onReceive(
            NotificationCenter.default.publisher(for: .toggleSelectionFilter)
        ) { _ in
            presentationState.showOnlySelected.toggle()
        }
    }

    func setupPhotoNavigationHandlers(presentationState: PresentationState)
        -> some View
    {
        return
            self
            .onReceive(
                NotificationCenter.default.publisher(for: .resetPhotoNavigation)
            ) { note in
                presentationState.currentPhoto = nil
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .navigateToPhoto)
            ) { note in
                guard let photo = note.object as? Photo else {
                    return
                }
                presentationState.currentPhoto = photo
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: .navigateToPreviousPhoto
                )
            ) { _ in
                presentationState.goToPreviousPhoto()
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .navigateToNextPhoto)
            ) { _ in
                presentationState.goToNextPhoto()
            }
    }

    func setupHandlers(
        modalPresenter: ModalService,
        notifier: NotificationService,
        fileImporter: FileImportService,
        alerter: AlertService,
        tagStore: TagStore
    ) -> some View {
        let editTagPresenter = EditTagPresenter(
            modalPresenter: modalPresenter,
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
        let pickTagPresenter = PickTagPresenter(
            modalPresenter: modalPresenter,
            notifier: notifier,
        )

        return
            self
            .onReceive(
                NotificationCenter.default.publisher(for: .requestImportPhotos)
            ) { _ in
                importPhotosPresenter.show()
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .requestCreateTag)
            ) { _ in
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
            .onReceive(
                NotificationCenter.default.publisher(for: .requestTagPhotos)
            ) { _ in
                pickTagPresenter.show()
            }
    }
}
