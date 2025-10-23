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
    ) -> some View {
        return self.onReceive(
            NotificationCenter.default.publisher(for: .loadDates)
        ) { _ in
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

                    notifier.show(
                        "Imported \(folder.lastPathComponent)",
                        .success
                    )
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
                presentationState.allPhotosSelected.toggle()
            }
    }

    func setupPresentationModeHandlers(presentationState: PresentationState)
        -> some View
    {
        return self.onReceive(
            NotificationCenter.default.publisher(for: .toggleSelectionMode)
        ) { _ in
            presentationState.isSelecting.toggle()
            presentationState.showOnlySelected = false
            presentationState.allPhotosSelected = false
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
    ) -> some View {
        let importPhotosPresenter = ImportPhotosPresenter(
            fileImporter: fileImporter,
            notifier: notifier
        )
        let pickTagPresenter = PickTagPresenter(modalPresenter: modalPresenter)

        return
            self
            .onReceive(
                NotificationCenter.default.publisher(for: .requestImportPhotos)
            ) { _ in
                importPhotosPresenter.show()
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .requestTagPhotos)
            ) { _ in
                pickTagPresenter.show()
            }
    }
}
