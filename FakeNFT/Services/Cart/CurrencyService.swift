import Foundation

final class CurrencyService{
    private let networkClient: NetworkClient
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    func fetchCurrency( completion: @escaping (Result<[Currency], Error>) -> Void) {
        var results: [Currency] = []
        let request = CurrencyRequest()
        networkClient.send(request: request, type: [Currency].self){ result in
            switch result {
            case .success(let currency):
                results.append(contentsOf: currency)
                completion(.success(results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
