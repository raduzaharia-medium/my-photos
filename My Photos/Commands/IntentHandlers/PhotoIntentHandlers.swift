import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension View {
    func setupPhotoHandlers(presentationState: PresentationState)
        -> some View
    {
        let selectPhotos: (NotificationCenter.Publisher.Output) -> Void = {
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
            self
            .onReceive(
                NotificationCenter.default.publisher(for: .selectPhotos),
                perform: selectPhotos
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
                NotificationCenter.default.publisher(for: .toggleSelection),
                perform: toggleSelection
            )
    }
}
