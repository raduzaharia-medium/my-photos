import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension View {
    func setupPlaceLoadingHandlers(
        presentationState: PresentationState,
        placeStore: PlaceStore,
    ) -> some View {
        return self.onReceive(
            NotificationCenter.default.publisher(for: .loadPlaces)
        ) { _ in
            let countries = placeStore.getCountries()
            presentationState.countries = countries
        }
    }
    func setupTagLoadingHandlers(
        presentationState: PresentationState,
        tagPickerState: TagPickerState,
        dateStore: DateStore,
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
            let parent = note.userInfo?["parent"] as? Tag

            do {
                try tagStore.update(
                    tag.persistentModelID,
                    name: name,
                    parent: parent
                )

                let tags = tagStore.getTags()
                presentationState.tags = tags
                notifier.show("Tag updated", .success)
            } catch {
                notifier.show("Could not update tag", .error)
            }
        }.onReceive(
            NotificationCenter.default.publisher(for: .createTag)
        ) { note in
            guard let name = note.userInfo?["name"] as? String else { return }

            do {
                try tagStore.create(name: name)

                let tags = tagStore.getTags()
                presentationState.tags = tags

                notifier.show("Tag created", .success)
            } catch {
                notifier.show("Could not create tag", .error)
            }
        }.onReceive(
            NotificationCenter.default.publisher(for: .deleteTag)
        ) { note in
            guard let tag = note.object as? Tag else { return }

            do {
                try tagStore.delete(tag.persistentModelID)
                presentationState.tags.removeAll(where: {
                    $0.persistentModelID == tag.persistentModelID
                })
                notifier.show("Tag deleted", .success)
            } catch {
                notifier.show("Could not delete tag", .error)
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .deleteTags)
        ) { note in
            guard let tags = note.object as? [Tag] else { return }
            let ids = Set(tags.map(\.persistentModelID))

            do {
                try tagStore.delete(tags.map(\.persistentModelID))
                presentationState.tags.removeAll {
                    ids.contains($0.persistentModelID)
                }
                notifier.show("Tags deleted", .success)
            } catch {
                notifier.show("Could not delete tags", .error)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .loadDates)) { _ in
            let years = dateStore.getYears()
            presentationState.years = years
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .loadTagSuggestions)
        ) { note in
            guard let searchText = note.object as? String else { return }

            withAnimation {
                let suggestions = presentationState.getTags(
                    searchText: searchText
                )
                tagPickerState.suggestions = suggestions
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .selectNextTagSuggestion)
        ) { note in
            withAnimation {
                tagPickerState.selectNext()
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: .selectPreviousTagSuggestion
            )
        ) { note in
            withAnimation {
                tagPickerState.selectPrevious()
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .addSelectedTagToEditor)
        ) { note in
            withAnimation {
                tagPickerState.addSelection()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .addTagToEditor)) {
            note in
            guard let tag = note.object as? Tag else { return }

            withAnimation {
                tagPickerState.addTag(tag)
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .removeTagFromEditor)
        ) { note in
            guard let tag = note.object as? Tag else { return }

            withAnimation {
                tagPickerState.removeTag(tag)
            }
        }
    }

    func setupPhotoLoadingHandlers(
        presentationState: PresentationState,
        notifier: NotificationService,
        photoStore: PhotoStore,
        tagStore: TagStore,
        fileStore: FileStore,
        dateStore: DateStore,
        placeStore: PlaceStore
    ) -> some View {
        return self.onReceive(
            NotificationCenter.default.publisher(for: .loadPhotos)
        ) { _ in
            withAnimation {
                let photos = photoStore.getPhotos()
                presentationState.photos = photos
            }
        }.onReceive(
            NotificationCenter.default.publisher(for: .importPhotos)
        ) { note in
            guard let folder = note.object as? URL else {
                notifier.show(
                    "Could not import folder",
                    .error
                )
                return
            }

            Task {
                if let parsedPhotos = try? await fileStore.parseImageFiles(
                    in: folder
                ) {
                    for parsedPhoto in parsedPhotos {
                        let tags = tagStore.ensure(parsedPhoto.tags)
                        let year = try? dateStore.ensureYear(
                            parsedPhoto.dateTaken
                        )
                        let month = try? dateStore.ensureMonth(
                            parsedPhoto.dateTaken
                        )
                        let day = try? dateStore.ensureDay(
                            parsedPhoto.dateTaken
                        )
                        let country = try? placeStore.ensureCountry(
                            parsedPhoto.country
                        )
                        let locality = try? placeStore.ensureLocality(
                            parsedPhoto.country,
                            parsedPhoto.locality
                        )

                        let photo = Photo(
                            title: parsedPhoto.title,
                            description: parsedPhoto.description,
                            dateTaken: parsedPhoto.dateTaken,
                            dateTakenYear: year,
                            dateTakenMonth: month,
                            dateTakenDay: day,
                            location: parsedPhoto.location,
                            country: country,
                            locality: locality,
                            tags: tags
                        )

                        try? photoStore.insert(photo)
                    }

                    let tags = tagStore.getTags()
                    presentationState.tags = tags

                    let years = dateStore.getYears()
                    presentationState.years = years

                    let countries = placeStore.getCountries()
                    presentationState.countries = countries

                    let refreshedPhotos = photoStore.getPhotos()
                    await MainActor.run {
                        withAnimation {
                            presentationState.photos = refreshedPhotos
                        }
                        notifier.show(
                            "Imported \(folder.lastPathComponent)",
                            .success
                        )
                    }
                } else {
                    await MainActor.run {
                        notifier.show(
                            "Could not import \(folder.lastPathComponent)",
                            .error
                        )
                    }
                }
            }
        }.onReceive(
            NotificationCenter.default.publisher(for: .resetPhotoFilter)
        ) { _ in
            withAnimation {
                presentationState.photoFilter.removeAll()
                presentationState.photoFilter.insert(SidebarItem.filter(.all))

                let photos = photoStore.getPhotos()
                presentationState.photos = photos
            }
        }.onReceive(
            NotificationCenter.default.publisher(for: .updatePhotoFilter)
        ) { note in
            guard let photoFilters = note.object as? Set<SidebarItem> else {
                return
            }

            withAnimation {
                presentationState.photoFilter.removeAll()
                presentationState.photoFilter.formUnion(photoFilters)

                let photos = photoStore.getPhotos(photoFilters)
                presentationState.photos = photos
            }
        }.onReceive(
            NotificationCenter.default.publisher(for: .tagSelectedPhotos)
        ) { note in
            guard let tags = note.object as? [Tag] else { return }

            do {
                try photoStore.tagPhotos(presentationState.selectedPhotos, tags)
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
            }.onReceive(
                NotificationCenter.default.publisher(
                    for: .toggleSelectAllPhotos
                )
            ) { note in
                if presentationState.selectedPhotos.count
                    != presentationState.photos.count
                {
                    presentationState.selectedPhotos.removeAll()
                    presentationState.selectedPhotos.formUnion(
                        presentationState.photos
                    )
                } else {
                    presentationState.selectedPhotos.removeAll()
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
            withAnimation {
                presentationState.showOnlySelected.toggle()
            }
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
        let editTagPresenter = EditTagPresenter(modalPresenter: modalPresenter)
        let importPhotosPresenter = ImportPhotosPresenter(
            fileImporter: fileImporter,
            notifier: notifier
        )
        let deleteTagPresenter = DeleteTagPresenter(alerter: alerter)
        let pickTagPresenter = PickTagPresenter(modalPresenter: modalPresenter)

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
