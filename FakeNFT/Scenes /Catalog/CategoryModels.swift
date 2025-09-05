import Foundation

struct Category {
    let id: String
    let title: String
    let count: Int
    let image: URL?
}

struct CategoriesRequest: NetworkRequest {
    var endpoint: URL? { URL(string: "\(RequestConstants.baseURL)/api/v1/collections") }
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
}

struct CategoryDTO: Decodable {
    let id: String
    let name: String
    let cover: String
    let nfts: [String]
    let description: String
    let author: String
    let createdAt: String
    
    func toDomain() -> Category {
        Category(
            id: id,
            title: name,
            count: nfts.count,
            image: URL(string: cover)
        )
    }
}

struct CollectionsResponse: Decodable {
    let items: [CategoryDTO]
}
