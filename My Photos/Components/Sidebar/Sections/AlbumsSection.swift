import SwiftData
import SwiftUI

struct AlbumsSection: View {
    @Query(sort: \Album.key) private var albums: [Album]

    var body: some View {
        Section("Albums") {
            ForEach(albums) { album in
                SidebarRow(.album(album)).tag(album)
                    .dropDestination(for: PhotoDragItem.self) { items, _ in
                        // TODO: do I need the dragged items if they are already in presentation state?
                        
                        PhotoIntents.requestChangeAlbum(album: album)
                        return true
                    }
            }
        }
    }
}
