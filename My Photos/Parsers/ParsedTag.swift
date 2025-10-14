struct ParsedTag {
    let name: String
    var children: [ParsedTag] = []
    
    mutating func addChild(_ child: ParsedTag) {
        children.append(child)
    }
}
