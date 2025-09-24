import Foundation

struct ProfileGetRequest: NetworkRequest {
    let profileId: String

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/\(profileId)")
    }

    var httpMethod: HttpMethod = .get
    var dto: Dto? = nil
}
