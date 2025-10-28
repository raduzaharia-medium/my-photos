import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension View {
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
            guard let photos = note.object as? [Photo] else { return }
            guard let tags = note.userInfo?["tags"] as? [SidebarItem] else {
                return
            }

            do {
                try photoStore.tagPhotos(photos, tags)
                notifier.show("Photos tagged", .success)
            } catch {
                notifier.show("Failed to tag photos", .error)
            }
        }.onReceive(
            NotificationCenter.default.publisher(for: .selectPhotos)
        ) { note in
            guard let photos = note.object as? [Photo] else { return }

            withAnimation {
                presentationState.photoSelection = Set(photos)
            }
        }.onReceive(NotificationCenter.default.publisher(for: .enablePhotoSelectionMode)) {
            _ in
            presentationState.photoSelectionMode = true
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .toggleSelection)
        ) { note in
            guard let photo = note.object as? Photo else { return }

            withAnimation {
                if presentationState.isSelected(photo) {
                    presentationState.photoSelection.remove(photo)
                } else {
                    presentationState.photoSelection.insert(photo)
                }
            }
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
            ) { note in
                guard let photos = note.object as? [Photo] else { return }
                pickTagPresenter.show(photos)
            }
    }
}
