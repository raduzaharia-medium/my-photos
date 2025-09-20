import Foundation

extension Collection where Element == Photo {
    func filtered(by sidebarSelection: Set<SidebarItem>) -> [Photo] {
        let selectedTags: [Tag] = sidebarSelection.compactMap {
            if case .tag(let t) = $0 { return t }
            return nil
        }

        guard !selectedTags.isEmpty else {
            return Array(self)
        }

        let filtered = self.filter { photo in
            photo.tags.contains { tag in
                selectedTags.contains(where: { $0 == tag })
            }
        }

        return filtered.sorted { $0.dateTaken > $1.dateTaken }
    }
}
