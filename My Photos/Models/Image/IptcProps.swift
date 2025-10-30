import Foundation
import ImageIO

struct IptcProps {
    private var iptcKey: CFString { "{IPTC}" as CFString }

    private var iptcDescrKey: CFString { kCGImagePropertyIPTCCaptionAbstract }
    private var iptcTitleKey: CFString { kCGImagePropertyIPTCObjectName }
    private var iptcLocationCreatedKey: CFString {
        kCGImagePropertyIPTCExtLocationCreated
    }
    private var iptcCountryKeyNew: CFString {
        kCGImagePropertyIPTCExtLocationCountryName
    }
    private var iptcCountryKey: CFString {
        kCGImagePropertyIPTCCountryPrimaryLocationName
    }
    private var iptcCityKeyNew: CFString { kCGImagePropertyIPTCExtLocationCity }
    private var iptcCityKey: CFString { kCGImagePropertyIPTCCity }

    private let props: [CFString: Any]

    init(_ props: [CFString: Any]) {
        self.props = props
    }

    var iptc: [CFString: Any]? { props[iptcKey] as? [CFString: Any] }

    var title: String? { iptc?[iptcTitleKey] as? String }
    var description: String? { iptc?[iptcDescrKey] as? String }
    var country: String? {
        let iptcCountry = iptc?[iptcCountryKey] as? String
        let iptcCountryNew = iptc?[iptcCountryKeyNew] as? String
        let iptcCreatedCountry = locationCreated?["CountryName"] as? String

        return iptcCreatedCountry ?? iptcCountryNew ?? iptcCountry
    }
    var city: String? {
        let iptcCity = iptc?[iptcCityKey] as? String
        let iptcCityNew = iptc?[iptcCityKeyNew] as? String
        let iptcCreatedCity = locationCreated?["City"] as? String

        return iptcCreatedCity ?? iptcCityNew ?? iptcCity
    }

    private var locationCreated: NSDictionary? {
        let result = iptc?[iptcLocationCreatedKey] as? [NSDictionary]
        return result?[0]
    }
}
