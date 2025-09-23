import Foundation

final class SortStorage {
    private enum Keys {
        static let myNftSort = "myNftSortOption"
    }
    
    static let shared = SortStorage()
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    var myNftSortOption: NftSortOption {
        get {
            let rawValue = userDefaults.string(forKey: Keys.myNftSort) ?? ""
            return NftSortOption(rawValue: rawValue) ?? .name
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Keys.myNftSort)
        }
    }
}

