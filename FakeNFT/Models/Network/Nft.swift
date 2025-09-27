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
        let nftTitle = extractNftTitle(from: name)
        let authorName = extractAuthorName(from: author)
        
        return Nft(
            id: id,
            title: nftTitle,  // Короткое имя NFT
            imagesUrl: images.compactMap { URL(string: $0) },
            rating: Double(rating),
            price: price,
            description: description,
            author: authorName,
            isFavorite: false,
            isInBasket: false
        )
    }
    
    private func extractNftTitle(from fullName: String) -> String {
        let components = fullName.split(separator: " ")
        return components.first.map(String.init) ?? fullName
    }
    
    private func extractAuthorName(from url: String) -> String {
        if let urlComponents = URLComponents(string: url),
           let host = urlComponents.host {
            let cleanHost = host.replacingOccurrences(of: ".fakenfts.org", with: "")
            let authorName = cleanHost
                .replacingOccurrences(of: "_", with: " ")
                .capitalized
            return authorName
        }
        
        return "Unknown Author"
    }
}

