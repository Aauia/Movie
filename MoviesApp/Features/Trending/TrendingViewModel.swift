import Foundation

final class TrendingViewModel {
    private let service: MoviesServiceProtocol
    private(set) var items: [Movie] = []
    private(set) var filteredItems: [Movie] = []
    private var currentSearchQuery: String = ""
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
            filteredItems.removeAll()
            hasMorePages = true
        }
        
        onStateChange?(.loading)
        
        do {
            let newMovies = try await service.getTrending(page: page)
            
            if reset && newMovies.isEmpty {
                onStateChange?(.empty)
            } else {
                items.append(contentsOf: newMovies)
                hasMorePages = !newMovies.isEmpty
                
                if currentSearchQuery.isEmpty {
                    filteredItems = items
                } else {
                    search(query: currentSearchQuery)
                }
                
                onStateChange?(.content(filteredItems))
                page += 1
            }
        } catch {
            onStateChange?(.error(error.localizedDescription))
        }
        
        isLoading = false
    }
    
    @MainActor
    func search(query: String) {
        currentSearchQuery = query
        
        if query.isEmpty {
            filteredItems = items
        } else {
            filteredItems = items.filter { movie in
                movie.title.localizedCaseInsensitiveContains(query) ||
                (movie.year?.contains(query) == true)
            }
        }
        
        if filteredItems.isEmpty && !items.isEmpty {
            onStateChange?(.empty)
        } else {
            onStateChange?(.content(filteredItems))
        }
    }
    
    func shouldLoadMore(for index: Int) -> Bool {
        return index >= filteredItems.count - 5 && hasMorePages && !isLoading && currentSearchQuery.isEmpty
    }
}
