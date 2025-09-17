struct ProfilePutDto: Dto/*, MultiValueFormDataDto*/ {
    let name: String?
    let avatar: String?
    let description: String?
    let website: String?
    let likes: [String]?

    func asDictionary() -> [String: String] {
        var dict: [String: String] = [:]
        if let name, !name.isEmpty { dict["name"] = name }
        if let avatar, !avatar.isEmpty { dict["avatar"] = avatar }
        if let description, !description.isEmpty { dict["description"] = description }
        if let website, !website.isEmpty { dict["website"] = website }
        return dict
    }

    func asFormURLEncodedPairs() -> [(String, String)] {
        guard let likes else { return [] }

        if likes.isEmpty {
            return [("likes", "null")]
        }

        return likes.map { ("likes", $0) }
    }
}
