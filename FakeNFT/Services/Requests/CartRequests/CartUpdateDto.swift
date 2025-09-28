import Foundation

struct CartUpdateDto: Dto {
    let nfts: [String]
    func asDictionary() -> [String: String] {
        return [
            "nfts": nfts.joined(separator: ",")
        ]
    }
}
struct CartClearDto: Dto {
    func asDictionary() -> [String : String] {
        return ["":""]
    }
}
