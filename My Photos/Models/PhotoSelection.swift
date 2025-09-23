import SwiftUI

enum PresentationMode: String, CaseIterable, Identifiable {
    case grid = "Grid"
    case map = "Map"

    var id: String { rawValue }
}

struct PhotosSelectionModePreferenceKey: PreferenceKey {
    static let defaultValue: Bool = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

struct PresentationModeKey: FocusedValueKey {
    typealias Value = Binding<PresentationMode>
}

extension FocusedValues {
    var presentationMode: Binding<PresentationMode>? {
        get { self[PresentationModeKey.self] }
        set { self[PresentationModeKey.self] = newValue }
    }
}
