import Foundation

final class UpcomingViewModel {
    private let service: MoviesServiceProtocol
    private(set) var items: [Movie] = []
    private(set) var sortedItems: [Movie] = []
    private var currentSort: SortOption = .none
    var onStateChange: ((ViewState<[Movie]>) -> Void)?
    private var page = 1
    private var isLoading = false
    private var hasMorePages = true
    
    init(service: MoviesServiceProtocol = MoviesService()) {
        self.service = service
    }
    
    @MainActor
    func load(reset: Bool = false) async {
        guard !isLoading, hasMorePages || reset else { return }
        isLoading = true
        
        if reset {
            page = 1
            items.removeAll()
            sortedItems.removeAll()
            hasMorePages = true
        }
        
        onStateChange?(.loading)
        
        do {
            let newMovies = try await service.getUpcoming(page: page)
            
            if reset && newMovies.isEmpty {
                onStateChange?(.empty)
            } else {
                items.append(contentsOf: newMovies)
                hasMorePages = !newMovies.isEmpty
                applySorting()
                onStateChange?(.content(sortedItems))
                page += 1
            }
        } catch {
            onStateChange?(.error(error.localizedDescription))
        }
        
        isLoading = false
    }
    
    func sort(by option: SortOption) {
        currentSort = option
        applySorting()
        onStateChange?(.content(sortedItems))
    }
    
    private func applySorting() {
        switch currentSort {
        case .none:
            sortedItems = items
        case .rating:
            sortedItems = items.sorted { lhs, rhs in
                let lhsRating = lhs.rating ?? 0
                let rhsRating = rhs.rating ?? 0
                return lhsRating > rhsRating
            }
        case .year:
            sortedItems = items.sorted { lhs, rhs in
                let lhsYear = Int(lhs.year ?? "0") ?? 0
                let rhsYear = Int(rhs.year ?? "0") ?? 0
                return lhsYear > rhsYear
            }
        }
    }
    
    func shouldLoadMore(for index: Int) -> Bool {
        return index >= sortedItems.count - 5 && hasMorePages && !isLoading
    }
    
    var currentSortOption: SortOption {
        return currentSort
    }
}
