import Foundation
import ImageIO

struct ImageProps {
    private var exifProps: ExifProps
    private var tiffProps: TiffProps
    private var iptcProps: IptcProps
    private var gpsProps: GpsProps
    private var qtProps: QtProps
    private var xmpProps: XmpProps

    init(_ props: [CFString: Any], _ meta: CGImageMetadata?) {
        self.exifProps = ExifProps(props)
        self.tiffProps = TiffProps(props)
        self.iptcProps = IptcProps(props)
        self.gpsProps = GpsProps(props)
        self.qtProps = QtProps(props)
        self.xmpProps = XmpProps(meta)
    }

    var title: String? { iptcProps.title ?? xmpProps.title ?? qtProps.title }
    var description: String? {
        tiffProps.description ?? iptcProps.description ?? xmpProps.description
    }
    var dateTaken: Date? { exifProps.dateTaken ?? tiffProps.dateTaken }
    var location: GeoCoordinate? { gpsProps.location }
    var country: String? { iptcProps.country ?? xmpProps.country }
    var city: String? { iptcProps.city ?? xmpProps.city }
    var album: String? { xmpProps.album }
}
