@testable import FakeNFT

final class MockCatalogService: CatalogServiceProtocol {
    enum Mode {
        case success([Category])
        case failure(Error)
    }
    
    var mode: Mode
    
    init(mode: Mode) {
        self.mode = mode
    }
    
    func fetchCollections(completion: @escaping (Result<[Category], Error>) -> Void) {
        switch mode {
        case .success(let items):
            completion(.success(items))
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
