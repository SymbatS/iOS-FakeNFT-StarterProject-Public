import Foundation


typealias NftCompletion = (Result<Nft, Error>) -> Void
typealias NftsCompletion = (Result<[Nft], Error>) -> Void

protocol NftService {
    func loadNft(id: String, completion: @escaping NftCompletion)
    func loadNfts(for categoryId: String, completion: @escaping NftsCompletion)
}

final class NftServiceImpl: NftService {
    
    private let networkClient: NetworkClient
    private let storage: NftStorage
    
    init(networkClient: NetworkClient, storage: NftStorage) {
        self.networkClient = networkClient
        self.storage = storage
    }
    
    func loadNft(id: String, completion: @escaping NftCompletion) {

        if let nft = storage.getNft(with: id) {
            completion(.success(nft))
            return
        }
        
        let request = NFTRequest(id: id)
        networkClient.send(request: request, type: NftDTO.self) { [weak self] result in
            switch result {
            case .success(let dto):
                let nft = dto.toDomain()
                self?.storage.saveNft(nft)
                completion(.success(nft))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loadNfts(for categoryId: String, completion: @escaping NftsCompletion) {
        let request = CategoryRequest(id: categoryId)
        networkClient.send(request: request, type: CategoryDTO.self) { [weak self] result in
            switch result {
            case .success(let categoryDTO):
                let ids = categoryDTO.nfts
                var nfts: [Nft] = []
                let group = DispatchGroup()
                var loadError: Error?
                
                for id in ids {
                    group.enter()
                    self?.loadNft(id: id) { result in
                        switch result {
                        case .success(let nft):
                            nfts.append(nft)
                        case .failure(let error):
                            loadError = error
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    if let error = loadError {
                        completion(.failure(error))
                    } else {
                        completion(.success(nfts))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
