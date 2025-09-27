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
    
    func updateCart(nft: [String], orderId: String, completion: @escaping (Result<CartResponse, Error>) -> Void) {
        let request = CartRequest(orderId: orderId)
        
        client.send(request: request, type: CartResponse.self) { [weak self] result in
            switch result {
            case .success(let cartResponse):
                var nfts: [String] = nft
                nfts.append(contentsOf: cartResponse.nfts)
                print(nfts)
                self?.updateNfts(orderId:"1",nfts:nfts, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
   private func updateNfts(orderId: String,nfts:[String],  completion: @escaping ((Result<CartResponse, Error>) -> Void)){
        let dto = CartUpdateDto(nfts: nfts)
        let request = CartUpdateRequest(dto: dto, orderId: orderId)
        client.send(request: request, type: CartResponse.self) { result in
            completion(result)
            print(result)
        }
    }
}
