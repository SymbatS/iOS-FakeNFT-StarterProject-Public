import Foundation

struct ProfilePutRequest: NetworkRequest {
    let profileId: String
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/\(profileId)")
    }

    var httpMethod: HttpMethod = .put
    var dto: Dto?

    init(profileId: String, profile: ProfilePutDto) {
        self.dto = profile
        self.profileId = profileId
    }
}
