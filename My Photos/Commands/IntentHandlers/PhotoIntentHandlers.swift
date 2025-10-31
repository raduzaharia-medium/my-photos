import Foundation
import SwiftUI
import UniformTypeIdentifiers

typealias NotificationOutput = NotificationCenter.Publisher.Output

extension View {
    func setupPhotoHandlers(
        presentationState: PresentationState,
        notifier: NotificationService,
        fileImporter: FileImportService,
        modalPresenter: ModalService,
        photoStore: PhotoStore,
        fileStore: FileStore,
        tagStore: TagStore,
        dateStore: DateStore,
        placeStore: PlaceStore,
        albumStore: AlbumStore,
        personStore: PersonStore
    ) -> some View {
        let importPhotosPresenter = ImportPhotosPresenter(
            fileImporter: fileImporter,
            notifier: notifier
        )
        let pickTagPresenter = PickTagPresenter(modalPresenter: modalPresenter)

        #if os(macOS)
            let importPhotos: (NotificationOutput) -> Void = { note in
                guard let folder = note.object as? URL else {
                    notifier.show("Could not import folder", .error)
                    return
                }
                guard let parsed = try? fileStore.parseImageFiles(in: folder)
                else {
                    notifier.show("Could not import folder", .error)
                    return
                }

                for item in parsed {
                    let tags = tagStore.ensure(item.tags)
                    let year = try? dateStore.ensureYear(item.dateTaken)
                    let month = try? dateStore.ensureMonth(item.dateTaken)
                    let day = try? dateStore.ensureDay(item.dateTaken)
                    let country = try? placeStore.ensureCountry(item.country)
                    let locality =
                        try? placeStore.ensureLocality(
                            item.country,
                            item.locality
                        )
                    let albums = albumStore.ensure(item.albums)
                    let names = item.regions?.regionList.map(\.name) ?? []
                    let people = personStore.ensure(names)

                    let photo = Photo(
                        fileName: item.fileName,
                        path: item.path,
                        bookmark: item.bookmark,
                        title: item.title,
                        description: item.description,
                        dateTaken: item.dateTaken,
                        dateTakenYear: year,
                        dateTakenMonth: month,
                        dateTakenDay: day,
                        location: item.location,
                        country: country,
                        locality: locality,
                        albums: albums,
                        people: people,
                        tags: tags,
                    )

                    try? photoStore.insert(photo)
                }

                notifier.show("Imported \(folder.lastPathComponent)", .success)
            }
        #endif

        let tagPhotos: (NotificationOutput) -> Void = {
            note in
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
        }

        let showImporter: (NotificationOutput) -> Void = { _ in
            importPhotosPresenter.show()
        }
        let showTagger: (NotificationOutput) -> Void = {
            note in
            guard let photos = note.object as? [Photo] else { return }
            pickTagPresenter.show(photos)
        }
        let clearSelection: (NotificationOutput) -> Void = {
            _ in
            presentationState.photoSelection.removeAll()
        }
        let select: (NotificationOutput) -> Void = {
            note in
            guard let photo = note.object as? Photo else { return }

            withAnimation {
                presentationState.photoSelection = Set([photo])
            }
        }
        let selectMany: (NotificationOutput) -> Void = {
            note in
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
