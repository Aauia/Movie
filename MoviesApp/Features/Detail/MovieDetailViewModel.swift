import Foundation

final class MovieDetailViewModel {
    private let service: MoviesServiceProtocol
    private(set) var movieDetail: MovieDetail?
    private(set) var similarMovies: [Movie] = []
    
    var onDetailStateChange: ((ViewState<MovieDetail>) -> Void)?
    var onSimilarStateChange: ((ViewState<[Movie]>) -> Void)?
    
    private var isLoadingDetail = false
    private var isLoadingSimilar = false
    
    init(service: MoviesServiceProtocol = MoviesService()) {
        self.service = service
    }
    
    @MainActor
    func loadDetail(id: String) async {
        guard !isLoadingDetail else { return }
        isLoadingDetail = true
        
        onDetailStateChange?(.loading)
        
        do {
            let detail = try await service.getMovie(id: id)
            movieDetail = detail
            onDetailStateChange?(.content(detail))
            
            try await Task.sleep(nanoseconds: 500_000_000)
            
            await loadSimilar(id: id)
        } catch {
            onDetailStateChange?(.error(error.localizedDescription))
        }
        
        isLoadingDetail = false
    }
    
    @MainActor
    func loadSimilar(id: String) async {
        print("🔄 Loading similar movies for ID: \(id)")
        guard !isLoadingSimilar else { 
            print("⚠️ Already loading similar movies, skipping...")
            return 
        }
        isLoadingSimilar = true
        
        onSimilarStateChange?(.loading)
        
        do {
            print("📡 Making API call for similar movies...")
            let similar = try await service.getSimilar(id: id, page: 1)
            print("✅ Similar movies API call successful: \(similar.count) movies")
            similarMovies = similar
            
            if similar.isEmpty {
                print("ℹ️ No similar movies found")
                onSimilarStateChange?(.empty)
            } else {
                print("🎬 Similar movies loaded successfully")
                onSimilarStateChange?(.content(similar))
            }
        } catch {
            print("❌ Error loading similar movies: \(error)")
            onSimilarStateChange?(.error(error.localizedDescription))
        }
        
        isLoadingSimilar = false
    }
    
    func retryDetail(id: String) {
        Task {
            await loadDetail(id: id)
        }
    }
    
    func retrySimilar(id: String) {
        Task {
            await loadSimilar(id: id)
        }
    }
    
    func setSimilarMovies(_ movies: [Movie]) {
        similarMovies = movies
    }
}
