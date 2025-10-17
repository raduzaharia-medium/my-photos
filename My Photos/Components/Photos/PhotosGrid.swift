import SwiftData
import SwiftUI

struct PhotosGrid: View {
    @Environment(PresentationState.self) private var presentationState
    @Query private var photos: [Photo]

    private static let columns = [
        GridItem(.adaptive(minimum: 110, maximum: 200), spacing: 8)
    ]

    init() {
        self._photos = Query(filters: presentationState.photoFilter)
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
        // Build a compound predicate by intersecting all selected sidebar filters
        let selectedDates = filters.selectedDates
        var yearKeys: [Int] = []
        var monthKeys: [(year: Int, month: Int)] = []
        var dayKeys: [(year: Int, month: Int, day: Int)] = []

        for d in selectedDates {
            switch d {
            case .year(let y): yearKeys.append(y.year)
            case .month(let m):
                monthKeys.append((year: m.year.year, month: m.month))
            case .day(let day):
                dayKeys.append(
                    (
                        year: day.month.year.year,
                        month: day.month.month,
                        day: day.day
                    )
                )
            }
        }

        //        let selectedTags = filters.selectedTags
        //        let selectedAlbums = filters.selectedAlbums
        //        let selectedEvents = filters.selectedEvents
        //        let selectedPeople = filters.selectedPeople
        //        let selectedPlaces = filters.selectedPlaces

        let filter = #Predicate<Photo> { $0.isDeleted == false
            // yearKeys.isEmpty && monthKeys.isEmpty && dayKeys.isEmpty

            //                || (!yearKeys.isEmpty
            //                    && yearKeys.contains { y in photo.dateTakenYear?.year == y })
            //                || (!monthKeys.isEmpty
            //                    && monthKeys.contains { key in
            //                        (photo.dateTakenYear?.year == key.year)
            //                            && (photo.dateTakenMonth?.month == key.month)
            //                    })
            //                || (!dayKeys.isEmpty
            //                    && dayKeys.contains { key in
            //                        (photo.dateTakenYear?.year == key.year)
            //                            && (photo.dateTakenMonth?.month == key.month)
            //                            && (photo.dateTakenDay?.day == key.day)
            //                    })

            //            // Tags: pass if none selected; else require all selected exist in photo.tags
            //            let matchesTags =
            //                selectedTags.isEmpty
            //                || selectedTags.allSatisfy { t in
            //                    photo.tags.contains { $0.id == t.id }
            //                }
            //
            //            // Albums: pass if none selected; else require all selected albums match
            //            let matchesAlbums =
            //                selectedAlbums.isEmpty
            //                || selectedAlbums.allSatisfy { a in
            //                    photo.album == a
            //                }
            //
            //            // People: pass if none selected; else require all present
            //            let matchesPeople =
            //                selectedPeople.isEmpty
            //                || selectedPeople.allSatisfy { p in
            //                    (photo.people?.contains { $0.id == p.id } ?? false)
            //                }
            //
            //            // Events: pass if none selected; else require all match
            //            let matchesEvents =
            //                selectedEvents.isEmpty
            //                || selectedEvents.allSatisfy { e in
            //                    photo.event == e
            //                }
            //
            //            // Places: pass if none selected; else match any of selected places
            //            let matchesPlaces =
            //                selectedPlaces.isEmpty
            //                || selectedPlaces.contains { place in
            //                    switch place {
            //                    case .country(let c): photo.country == c
            //                    case .locality(let l): photo.locality == l
            //                    }
            //                }
            //
            //            return matchesDate && matchesTags && matchesAlbums && matchesPeople
            //                && matchesEvents && matchesPlaces
        }

        let sort = [SortDescriptor(\Photo.dateTaken, order: .reverse)]
        self.init(filter: filter, sort: sort)
    }
}
