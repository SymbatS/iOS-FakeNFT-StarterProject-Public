import Foundation

struct PaymentRequest: NetworkRequest {
    var dto: (any Dto)?
    var currencyID: String
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1/payment/\(currencyID)")
    }
    var httpMethod: HttpMethod { .get }
}

