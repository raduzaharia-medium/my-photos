import Foundation
import ImageIO

struct ACDSeeRegions {
    private var acdSeeRegionsKey: CFString { "acdsee-rs:Regions" as CFString }
    private var acdSeeAppliedToDimensionsKey: CFString {
        "acdsee-rs:AppliedToDimensions" as CFString
    }
    private var acdSeeHKey: CFString { "acdsee-stDim:h" as CFString }
    private var acdSeeWKey: CFString { "acdsee-stDim:w" as CFString }
    private var acdSeeUnitKey: CFString { "acdsee-stDim:unit" as CFString }
    private var acdSeeRegionListKey: CFString {
        "acdsee-rs:RegionList" as CFString
    }
    private var algAreaKey: CFString { "acdsee-rs:ALGArea" as CFString }
    private var dlyAreaKey: CFString { "acdsee-rs:DLYArea" as CFString }
    private var areaHKey: CFString { "acdsee-stArea:h" as CFString }
    private var areaWKey: CFString { "acdsee-stArea:w" as CFString }
    private var areaXKey: CFString { "acdsee-stArea:x" as CFString }
    private var areaYKey: CFString { "acdsee-stArea:y" as CFString }
    private var nameKey: CFString { "acdsee-rs:Name" as CFString }
    private var assignTypeKey: CFString {
        "acdsee-rs:NameAssignType" as CFString
    }
    private var typeKey: CFString { "acdsee-rs:Type" as CFString }

    private let meta: CGImageMetadata?

    init(_ meta: CGImageMetadata?) { self.meta = meta }

    var regions: Regions? {
        guard let appliedToDimensions else { return nil }
        guard let regionList else { return nil }

        return Regions(
            appliedToDimensions: appliedToDimensions,
            regionList: regionList
        )
    }

    var appliedToDimensions: AppliedToDimensions? {
        guard let hString = appliedToDimensionsHString else { return nil }
        guard let wString = appliedToDimensionsWString else { return nil }
        guard let unit = appliedToDimensionsUnitString else { return nil }

        guard let height = Double(hString) else { return nil }
        guard let width = Double(wString) else { return nil }

        return AppliedToDimensions(
            size: Size(width: width, height: height),
            unit: unit
        )
    }
    var regionList: [Region]? {
        guard let regionListArray else { return nil }
        var result: [Region] = []

        for region in regionListArray {
            if let item = parseRegion(region) {
                result.append(item)
            }
        }
        
        return result
    }

    private var regionsTag: CGImageMetadataTag? {
        guard let meta else { return nil }
        return CGImageMetadataCopyTagWithPath(meta, nil, acdSeeRegionsKey)
    }

    private var appliedToDimensionsTag: CGImageMetadataTag? {
        guard let meta else { return nil }
        guard let parent = regionsTag else { return nil }

        return CGImageMetadataCopyTagWithPath(
            meta,
            parent,
            acdSeeAppliedToDimensionsKey
        )
    }
    private var appliedToDimensionsHTag: CGImageMetadataTag? {
        guard let meta else { return nil }
        guard let parent = appliedToDimensionsTag else { return nil }

        return CGImageMetadataCopyTagWithPath(meta, parent, acdSeeHKey)
    }
    private var appliedToDimensionsWTag: CGImageMetadataTag? {
        guard let meta else { return nil }
        guard let parent = appliedToDimensionsTag else { return nil }

        return CGImageMetadataCopyTagWithPath(meta, parent, acdSeeWKey)
    }
    private var appliedToDimensionsUnitTag: CGImageMetadataTag? {
        guard let meta else { return nil }
        guard let parent = appliedToDimensionsTag else { return nil }

        return CGImageMetadataCopyTagWithPath(meta, parent, acdSeeUnitKey)
    }

    private var regionListTag: CGImageMetadataTag? {
        guard let meta else { return nil }
        guard let parent = regionsTag else { return nil }

        return CGImageMetadataCopyTagWithPath(meta, parent, acdSeeRegionListKey)
    }
    private var regionListArray: [CGImageMetadataTag]? {
        guard let tag = regionListTag else { return nil }
        return CGImageMetadataTagCopyValue(tag) as? [CGImageMetadataTag]
    }

    private var appliedToDimensionsHString: String? {
        guard let appliedToDimensionsHTag else { return nil }
        return CGImageMetadataTagCopyValue(appliedToDimensionsHTag) as? String
    }
    private var appliedToDimensionsWString: String? {
        guard let appliedToDimensionsWTag else { return nil }
        return CGImageMetadataTagCopyValue(appliedToDimensionsWTag) as? String
    }
    private var appliedToDimensionsUnitString: String? {
        guard let appliedToDimensionsUnitTag else { return nil }
        return CGImageMetadataTagCopyValue(appliedToDimensionsUnitTag)
            as? String
    }

    private func parseRegion(_ tag: CGImageMetadataTag) -> Region? {
        guard let meta else { return nil }

        let algAreaTag = CGImageMetadataCopyTagWithPath(meta, tag, algAreaKey)
        let algXTag = CGImageMetadataCopyTagWithPath(meta, algAreaTag, areaXKey)
        let algYTag = CGImageMetadataCopyTagWithPath(meta, algAreaTag, areaYKey)
        let algWTag = CGImageMetadataCopyTagWithPath(meta, algAreaTag, areaWKey)
        let algHTag = CGImageMetadataCopyTagWithPath(meta, algAreaTag, areaHKey)

        let dlyAreaTag = CGImageMetadataCopyTagWithPath(meta, tag, dlyAreaKey)
        let dlyXTag = CGImageMetadataCopyTagWithPath(meta, dlyAreaTag, areaXKey)
        let dlyYTag = CGImageMetadataCopyTagWithPath(meta, dlyAreaTag, areaYKey)
        let dlyWTag = CGImageMetadataCopyTagWithPath(meta, dlyAreaTag, areaWKey)
        let dlyHTag = CGImageMetadataCopyTagWithPath(meta, dlyAreaTag, areaHKey)

        let nameTag = CGImageMetadataCopyTagWithPath(meta, tag, nameKey)
        let assignTag = CGImageMetadataCopyTagWithPath(meta, tag, assignTypeKey)
        let typeTag = CGImageMetadataCopyTagWithPath(meta, tag, typeKey)
                
        guard let algXString = getValue(tag: algXTag) else { return nil }
        guard let algYString = getValue(tag: algYTag) else { return nil }
        guard let algWString = getValue(tag: algWTag) else { return nil }
        guard let algHString = getValue(tag: algHTag) else { return nil }
                
        guard let algX = Double(algXString) else { return nil }
        guard let algY = Double(algYString) else { return nil }
        guard let algW = Double(algWString) else { return nil }
        guard let algH = Double(algHString) else { return nil }
        
        guard let dlyXString = getValue(tag: dlyXTag) else { return nil }
        guard let dlyYString = getValue(tag: dlyYTag) else { return nil }
        guard let dlyWString = getValue(tag: dlyWTag) else { return nil }
        guard let dlyHString = getValue(tag: dlyHTag) else { return nil }
                
        guard let dlyX = Double(dlyXString) else { return nil }
        guard let dlyY = Double(dlyYString) else { return nil }
        guard let dlyW = Double(dlyWString) else { return nil }
        guard let dlyH = Double(dlyHString) else { return nil }
        
        guard let name = getValue(tag: nameTag) else { return nil }
        guard let assign = getValue(tag: assignTag) else { return nil }
        guard let type = getValue(tag: typeTag) else { return nil }
                        
        return Region(
            algArea: Area(
                center: Point(x: algX, y: algY),
                size: Size(width: algW, height: algH)
            ),
            dlyArea: Area(
                center: Point(x: dlyX, y: dlyY),
                size: Size(width: dlyW, height: dlyH)
            ),
            name: name,
            nameAssignType: assign,
            type: type
        )
    }

    private func getValue(tag: CGImageMetadataTag?) -> String? {
        guard let tag else { return nil }
        return CGImageMetadataTagCopyValue(tag) as? String
    }
}
