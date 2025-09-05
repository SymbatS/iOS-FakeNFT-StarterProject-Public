import UIKit

final class AppPreferences {
    static let shared = AppPreferences()
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let catalogSort = "catalog.sort"
        static let isFirstLaunch = "app.isFirstLaunch"
    }
    // MARK: - Sorting
    enum SortOption: String {
        case byNftCount
        case byTitle
        case `default`
    }
    // MARK: - Catalog
    var catalogSort: SortOption {
        get {
            if let raw = defaults.string(forKey: Keys.catalogSort),
               let sort = SortOption(rawValue: raw) {
                return sort
            }
            return .default
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.catalogSort)
        }
    }
    
    // MARK: - Example
    var isFirstLaunch: Bool {
        get { !defaults.bool(forKey: Keys.isFirstLaunch) }
        set { defaults.set(!newValue, forKey: Keys.isFirstLaunch) }
    }
}

