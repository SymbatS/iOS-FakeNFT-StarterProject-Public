import Foundation

protocol CatalogService {
    func fetchCollections(completion: @escaping (Result<[Category], Error>) -> Void)
}

final class CatalogServiceImpl: CatalogService {
    private let client: NetworkClient
    init(client: NetworkClient) { self.client = client }
    
    func fetchCollections(completion: @escaping (Result<[Category], Error>) -> Void) {
        let req = CategoriesRequest()
        client.send(request: req, type: [CategoryDTO].self, completionQueue: .main) { result in
            switch result {
            case .success(let dtos):
                completion(.success(dtos.map { $0.toDomain() }))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
