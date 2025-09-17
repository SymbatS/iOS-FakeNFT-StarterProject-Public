import Foundation

struct ProfilePutRequest: NetworkRequest {
    let httpMethod: HttpMethod = .put
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }
    
    var dto: Dto?
    
    init(profile: Profile) {
        self.dto = ProfilePutDto(
            name: profile.name,
            avatar: profile.avatar,
            description: profile.description,
            website: profile.website,
            likes: profile.likes
        )
    }
}
