import Foundation
protocol MultiValueFormDataDto {
    func asFormURLEncodedPairs() -> [(String, String)]
}

struct ProfilePutDto: Dto, MultiValueFormDataDto {
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
        
        
        // ✅ Формат: likes = "id1,id2,id3"
        if let likes, !likes.isEmpty {
            dict["likes"] = likes.joined(separator: ",")
            print("📝 Added likes as comma-separated: \(likes.joined(separator: ","))")
        } else {
            dict["likes"] = ""
            print("📝 Added empty likes string")
        }
        return dict
    }

    func asFormURLEncodedPairs() -> [(String, String)] {
        print("🔗 asFormURLEncodedPairs called")
        guard let likes else {
            print("📝 No likes provided, returning empty")
            return []
        }
        
        if likes.isEmpty {
            print("📝 Empty likes array, sending null")
            return [("likes", "null")]
        }
        
        let pairs = likes.map { ("likes", $0) }
        print("📝 Form data pairs for likes: \(pairs)")
        return pairs
    }
}
