import Foundation

protocol ProfileServiceProtocol {
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void)
    func updateProfile(
        name: String?,
        avatar: String?,
        description: String?,
        website: String?,
        likes: [String]?,
        completion: @escaping (Result<Profile, Error>) -> Void
    )
}

final class ProfileService: ProfileServiceProtocol {
    private let networkClient: NetworkClient
    private let profileId: String
    private var lastFetchedProfile: Profile?

    init(networkClient: NetworkClient, profileId: String) {
        self.networkClient = networkClient
        self.profileId = profileId
    }

    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        let request = ProfileGetRequest(profileId: profileId)

        networkClient.send(request: request) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let data):
                do {
                    var profile = try JSONDecoder().decode(Profile.self, from: data)
                    profile = self.normalizedProfile(profile)
                    self.lastFetchedProfile = profile
                    completion(.success(profile))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func updateProfile(
        name: String?,
        avatar: String?,
        description: String?,
        website: String?,
        likes: [String]?,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        let dto = ProfilePutDto(
            name: name,
            avatar: avatar,
            description: description,
            website: website,
            likes: likes
        )
        let request = ProfilePutRequest(profileId: profileId, profile: dto)

        networkClient.send(request: request, type: Profile.self) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let updatedProfile):
                let normalized = self.normalizedProfile(updatedProfile)
                self.lastFetchedProfile = normalized
                completion(.success(normalized))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // TODO: Remove when API returns correct IPFS URLs
    private func updatedAvatarURL(from url: String) -> String {
        url.replacingOccurrences(
            of: "https://cloudflare-ipfs.com/ipfs/",
            with: "https://ipfs.io/ipfs/"
        )
    }

    private func normalizedProfile(_ profile: Profile) -> Profile {
        let updatedAvatar = profile.avatar.contains("cloudflare-ipfs.com")
            ? updatedAvatarURL(from: profile.avatar)
            : profile.avatar

        let updatedNfts: [String] = profile.nfts.isEmpty
            ? [] 
            : profile.nfts
        
        return Profile(
            id: profile.id,
            name: profile.name,
            avatar: updatedAvatar,
            description: profile.description,
            website: profile.website,
            nfts: updatedNfts,
            likes: profile.likes
        )
    }
}
