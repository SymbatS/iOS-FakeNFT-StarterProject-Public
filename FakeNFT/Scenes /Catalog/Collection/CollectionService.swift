import Foundation

protocol CollectionServiceProtocol {
    func fetchNfts(for collectionId: String,
                   completion: @escaping (Result<[Nft], Error>) -> Void)
}

final class CollectionService: CollectionServiceProtocol {
    private let client: NetworkClient
    
    init(client: NetworkClient) {
        self.client = client
    }
    
    func fetchNfts(for collectionId: String,
                   completion: @escaping (Result<[Nft], Error>) -> Void) {
        let request = CollectionNftsRequest(id: collectionId)
        client.send(request: request,
                    type: [NftDTO].self,
                    completionQueue: .main) { result in
            switch result {
            case .success(let nftDTOs):
                completion(.success(nftDTOs.map { $0.toDomain() }))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
