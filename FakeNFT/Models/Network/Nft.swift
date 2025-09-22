import Foundation

struct Nft: Decodable {
    let id: String
    let title: String
    let imagesUrl: [URL]
    let rating: Double
    let price: Double
    let description: String
    let author: String
    var isFavorite: Bool
    var isInBasket: Bool
}

struct NftDTO: Decodable {
    let id: String
    let name: String
    let images: [String]
    let rating: Int
    let description: String
    let price: Double
    let author: String
    let createdAt: String
    
    func toDomain() -> Nft {
        Nft(
            id: id,
            title: name,  
            imagesUrl: images.compactMap { URL(string: $0) },
            rating: Double(rating),
            price: price,
            description: description,
            author: author,
            isFavorite: false,
            isInBasket: false
        )
    }
}
