import SwiftData
import SwiftUI

struct AlbumsSection: View {
    @Query(sort: \Album.key) private var albums: [Album]

    var body: some View {
        Section("Albums") {
            ForEach(albums) { album in
                SidebarRow(.album(album)).tag(album)
            }
        }
    }
}
