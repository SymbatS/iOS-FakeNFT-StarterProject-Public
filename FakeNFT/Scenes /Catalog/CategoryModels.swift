import Foundation

struct Category {
    let id: String
    let title: String
    let count: Int
    let image: URL?
    let description: String
    let author: String
    let authorURL: URL
}

struct CategoriesRequest: NetworkRequest {
    var endpoint: URL? { URL(string: "\(RequestConstants.baseURL)/api/v1/collections") }
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
}

struct CategoryRequest: NetworkRequest {
    let id: String
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/collections/\(id)")
    }
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
}

struct CollectionNftsRequest: NetworkRequest {
    typealias Response = [NftDTO]
    
    let id: String
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/collections/\(id)/nfts")
    }
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
}

struct CollectionNftsResponse: Decodable {
    let items: [NftDTO]
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
            image: URL(string: cover),
            description: description,
            author: author,
            authorURL: URL(string: "https://practicum.yandex.kz/ios-developer/?utm_source=google&utm_medium=cpc&utm_campaign=Gog_Sch_KZ_Prog_iOS_b2c_Gener_Regular_1&utm_content=nt_g%3Apl_%3Acid_21246811347%3Agid_167230097204%3Akw_ios+%D1%80%D0%B0%D0%B7%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D1%87%D0%B8%D0%BA%3Atid_kwd-301893993516%3Acrid_708097904523%3Aadp_%3Ad_c%3Adm_%3Alim_%3Alpm_9196137&utm_term=ios+%D1%80%D0%B0%D0%B7%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D1%87%D0%B8%D0%BA&gad_source=1&gad_campaignid=21246811347&gbraid=0AAAAAqA9dPGBNxsPMerZmi1lo0iGhZWVF&gclid=Cj0KCQjw5onGBhDeARIsAFK6QJacQSXQZHbSJPq_hu4QyEkzNDjzi2RmDBQV7gc3gdAoKuG6cK4eMXMaAgToEALw_wcB")!
        )
    }
}

struct CollectionsResponse: Decodable {
    let items: [CategoryDTO]
}


