import SwiftData
import SwiftUI

struct PhotosMap: View {
    let selectedItem: SidebarItem?
    
    init(_ selectedItem: SidebarItem?) {
        self.selectedItem = selectedItem
    }

    var body: some View {
        if selectedItem == nil {
            ContentUnavailableView(
                "Select a tag",
                systemImage: "tag.slash",
                description: Text("Let's browse all photos.")
            )
        } else {
            Text(selectedItem?.name ?? "Unknown Tag")
        }
    }
}
