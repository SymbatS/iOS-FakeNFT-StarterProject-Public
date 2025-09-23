import Foundation
import UIKit

protocol NftView: AnyObject {
    func reloadData()
}

enum NftSortOption: String, CaseIterable {
    case name = "name"
    case price = "price"
    case rating = "rating"
    
    var localizedTitle: String {
        switch self {
        case .name:
            return NSLocalizedString("MyNftViewController.sortMenuName", comment: "")
        case .price:
            return NSLocalizedString("MyNftViewController.sortMenuPrice", comment: "")
        case .rating:
            return NSLocalizedString("MyNftViewController.sortMenuRating", comment: "")
        }
    }
}


final class NftHandler: LoadingView {
    
    private weak var view: NftView?
    private let nftService: NftService
    private(set) var nftIDs: [String]
    private var nfts: [Nft] = []
    
    private var currentSortOption: NftSortOption = .name

    internal lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    init(view: NftView, services: ServicesAssembly, nftIDs: [String]) {
        self.view = view
        self.nftService = services.nftService
        self.nftIDs = nftIDs
    }
    
    func viewDidLoad() {
        currentSortOption = SortStorage.shared.myNftSortOption
        reloadNfts()
    }
    
    func updateNftIDs(_ newIDs: [String]) {
        
        guard newIDs != nftIDs else { return }
        
        nftIDs = newIDs
        
        if newIDs.isEmpty {
            nfts.removeAll()
            view?.reloadData()
            return
        }
        reloadNfts()
    }
    
    private func reloadNfts() {
        guard !nftIDs.isEmpty else { return }
        nfts.removeAll()
        view?.reloadData()
        showLoading()
        loadNextNft(at: 0)
    }
    
    private func loadNextNft(at index: Int) {
        guard index < nftIDs.count else {
            DispatchQueue.main.async {
                self.hideLoading()
                self.applySavedSort()
                self.view?.reloadData()
            }
            return
        }
        
        let id = nftIDs[index]
        nftService.loadNft(id: id) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let nft):
                    self.nfts.append(nft.toDomain())
                case .failure(let error):
                    print("Failed to load NFT with id \(id):", error)
                }
                
                self.loadNextNft(at: index + 1)
            }
        }
    }
    
    func sort(by option: NftSortOption) {
        currentSortOption = option
        SortStorage.shared.myNftSortOption = option
        
        applySortOption(option)
        view?.reloadData()
    }
    
    private func applySavedSort() {
          applySortOption(currentSortOption)
      }
      
      private func applySortOption(_ option: NftSortOption) {
          switch option {
          case .name:
              nfts.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
          case .price:
              nfts.sort { $0.price < $1.price }
          case .rating:
              nfts.sort { $0.rating > $1.rating }
          }
      }
    
    var numberOfItems: Int {
        return nfts.count
    }
    
    func item(at index: Int) -> Nft {
        return nfts[index]
    }
}

extension NftHandler {
    func removeNft(withID id: String) -> Int? {
        guard let index = nfts.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        
        nfts.remove(at: index)
        
        if let idIndex = nftIDs.firstIndex(of: id) {
            nftIDs.remove(at: idIndex)
        }
        
        return index
    }
    
    func getNft(withID id: String) -> (nft: Nft, index: Int)? {
        guard let index = nfts.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        return (nfts[index], index)
    }
}

