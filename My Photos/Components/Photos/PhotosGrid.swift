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

        var year: Int? = nil
        var month: Int? = nil
        var day: Int? = nil

        if case .year(let date) = firstDate { year = date.year }
        if case .month(let date) = firstDate { month = date.month }
        if case .day(let date) = firstDate { day = date.day }

        let hasAnyFilter = (day != nil) || (month != nil) || (year != nil)
        let sort = [SortDescriptor(\Photo.dateTaken)]

        if hasAnyFilter {
            let filter = #Predicate<Photo> {
                (day != nil && $0.dateTakenDay?.day == day)
                    || (month != nil && $0.dateTakenMonth?.month == month)
                    || (year != nil && $0.dateTakenYear?.year == year)
            }

            self.init(filter: filter, sort: sort)
        } else {
            self.init(sort: sort)
        }
    }
}
