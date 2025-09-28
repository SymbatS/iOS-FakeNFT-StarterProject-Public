import Foundation

final class PaymentService{
    private let networkClient: NetworkClient
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    func tryPayment(currencyId:String ,completion: @escaping (Result<PaymentModel, Error>) -> Void) {
        let request = PaymentRequest(currencyID: currencyId)
        networkClient.send(request: request, type: PaymentModel.self){ result in
            switch result {
            case .success(let payment):
                CartService(networkClient: self.networkClient).cartClear(){ result in
                    switch result {
                    case .success(_):
                        print("Successfull payment")
                    case .failure(let error):
                        print(error)
                    }
                    
                }
                completion(.success(payment))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
