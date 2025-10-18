import SwiftData
import SwiftUI

struct PhotosGrid: View {
    @Environment(PresentationState.self) private var presentationState
    @Query private var photos: [Photo]

    private static let columns = [
        GridItem(.adaptive(minimum: 110, maximum: 200), spacing: 8)
    ]

    init(filters: Set<SidebarItem>) {
        self._photos = Query(filters: filters)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Self.columns, spacing: 8) {
                    ForEach(photos) { photo in
                        if presentationState.isSelecting {
                            PhotoCard(
                                photo,
                                variant: .selectable,
                                isSelected: presentationState.allPhotosSelected
                                    || presentationState.isPhotoSelected(photo)
                            )
                            .onTapGesture {
                                AppIntents.togglePhotoSelection(photo)
                            }
                            .draggable(PhotoDragItem(photo.id)) {
                                DragPreviewStack(
                                    count: presentationState.selectedPhotos
                                        .count
                                )
                            }
                        } else {
                            NavigationLink(value: photo) {
                                PhotoCard(photo, variant: .grid)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.all)
            }
            .navigationDestination(for: Photo.self) { photo in
                PhotoNavigator()
                    .onAppear {
                        AppIntents.navigateToPhoto(photo)
                    }
                    .onDisappear {
                        AppIntents.resetPhotoNavigation()
                    }
            }
            .toolbar {
                PhotosGridToolbar()
            }
        }
    }
}

extension Query where Element == Photo, Result == [Photo] {
    fileprivate init(filters: Set<SidebarItem>) {
        let dates = filters.selectedDates
        let firstDate = dates.first
        var year = 0

        switch firstDate {
        case .year(let date): year = date.year
        case .month(let date): year = date.year.year
        case .day(let date): year = date.month.year.year
        case .none: year = 0
        }

        let firstFilter = filters.first
        let firstAlbum = firstFilter?.name ?? ""

        let filter = #Predicate<Photo> {
            $0.dateTakenYear?.year ?? 2022 == year
        }
        let sort = [SortDescriptor(\Photo.dateTaken)]

        self.init(filter: filter, sort: sort)
    }
}
