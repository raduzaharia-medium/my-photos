import Foundation
import ImageIO

struct QtProps {
    private var qtKey: CFString { "{QuickTime}" as CFString }

    private var qtTitleKey: CFString { "Title" as CFString }

    private let props: [CFString: Any]

    init(_ props: [CFString: Any]) {
        self.props = props
    }

    var qt: [CFString: Any]? { props[qtKey] as? [CFString: Any] }

    var title: String? { qt?[qtTitleKey] as? String }
}
