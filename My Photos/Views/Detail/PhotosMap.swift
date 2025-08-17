import SwiftData
import SwiftUI

struct PhotosMap: View {
    let tag: Tag?

    var body: some View {
        if tag == nil {
            ContentUnavailableView(
                "Select a tag",
                systemImage: "tag.slash",
                description: Text("Let's browse all photos.")
            )
        } else {
            Text(tag?.name ?? "Unknown Tag")
        }
    }
}
