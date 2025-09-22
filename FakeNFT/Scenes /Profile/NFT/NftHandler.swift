import Foundation
import UIKit

protocol NftView: AnyObject {
    func reloadData()
}

enum NftSortOption {
    case name
    case price
    case rating
}

final class NftHandler: LoadingView {
    internal lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private weak var view: NftView?
    private let nftService: NftService
    private(set) var nftIDs: [String]
    private var nfts: [Nft] = []
    
    init(view: NftView, services: ServicesAssembly, nftIDs: [String]) {
        self.view = view
        self.nftService = services.nftService
        self.nftIDs = nftIDs
    }
    
    func viewDidLoad() {
        reloadNfts()
    }
    
    func updateNftIDs(_ newIDs: [String]) {
        print("🔧 NftHandler.updateNftIDs called")
        print("📋 Old IDs: \(nftIDs)")
        print("📋 New IDs: \(newIDs)")
        
        guard newIDs != nftIDs else {
            print("⚠️ IDs are the same, skipping")
            return
        }
        
        nftIDs = newIDs
        
        if newIDs.isEmpty {
            print("📭 New IDs empty, clearing NFTs")
            nfts.removeAll()
            view?.reloadData()
            return
        }
        
        print("🔄 Reloading NFTs...")
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
        switch option {
        case .name:
            nfts.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .price:
            nfts.sort { $0.price < $1.price }
        case .rating:
            nfts.sort { $0.rating > $1.rating }
        }
        view?.reloadData()
    }
    
    var numberOfItems: Int {
        return nfts.count
    }
    
    func item(at index: Int) -> Nft {
        return nfts[index]
    }
}
