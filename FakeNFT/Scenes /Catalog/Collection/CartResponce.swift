import Foundation

struct CartResponse: Decodable {
    let id: String
    let nfts: [String]
}
