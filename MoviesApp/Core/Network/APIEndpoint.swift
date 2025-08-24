import Foundation

enum APIEndpoint {
    static let baseURL = URL(string: "https://movies-tv-shows-database.p.rapidapi.com/")!
    
    case trending(page: Int)
    case nowPlaying(page: Int)
    case upcoming(page: Int)
    case movie(id: String)
    case similar(id: String, page: Int)
    case recentlyAdded(page: Int)
    case moviesByTitle(title: String, page: Int)
    case movieImages(imdbId: String)
    case movieAliases(imdbId: String)
    
    var url: URL {
        var components = URLComponents(url: Self.baseURL, resolvingAgainstBaseURL: true)!
        
        // Set the query parameters based on endpoint type
        var queryItems: [URLQueryItem] = []
        
        switch self {
        case .trending(let page):
            // Use trending endpoint starting from page 2 (page 1 is empty)
            // For full pagination: app page 1 = API page 2, app page 2 = API page 3, etc.
            let actualPage = page + 1  // Skip empty page 1
            queryItems = [
                URLQueryItem(name: "page", value: "\(actualPage)")
            ]
            
        case .nowPlaying(let page):
            // Use recently-added-movies endpoint with offset for different content
            // Now Playing: Use pages 11-20 for different movies
            let actualPage = page + 10  // Offset by 10 pages for different content
            queryItems = [
                URLQueryItem(name: "page", value: "\(actualPage)")
            ]
            
        case .upcoming(let page):
            // Use recently-added-movies endpoint with larger offset for different content
            // Upcoming: Use pages 21-30 for different movies
            let actualPage = page + 20  // Offset by 20 pages for different content
            queryItems = [
                URLQueryItem(name: "page", value: "\(actualPage)")
            ]
            
        case .recentlyAdded(let page):
            // Start from page 2 since page 1 returns empty data
            let actualPage = page + 1  // Skip empty page 1
            queryItems = [
                URLQueryItem(name: "page", value: "\(actualPage)")
            ]
            
        case .movie(let id):
            queryItems = [
                URLQueryItem(name: "movieid", value: id)
            ]
            
        case .similar(let id, let page):
            queryItems = [
                URLQueryItem(name: "movieid", value: id),
                URLQueryItem(name: "page", value: "\(page)")
            ]
            print("🔗 Similar movies endpoint - ID: \(id), page: \(page)")
            print("🔗 Similar movies URL: \(Self.baseURL) with query: \(queryItems)")
            
        case .moviesByTitle(let title, let page):
            queryItems = [
                URLQueryItem(name: "title", value: title),
                URLQueryItem(name: "page", value: "\(page)")
            ]
            
        case .movieImages(let imdbId):
            queryItems = [
                URLQueryItem(name: "movieid", value: imdbId)
            ]
            
        case .movieAliases(let imdbId):
            queryItems = [
                URLQueryItem(name: "movieid", value: imdbId)
            ]
        }
        
        components.queryItems = queryItems
        return components.url!
    }
    
    var httpMethod: String {
        return "GET"
    }
    
    // The Type header that this specific API expects
    var typeHeader: String {
        switch self {
        case .trending:
            return "get-trending-movies"
        case .nowPlaying:
            return "get-nowplaying-movies"
        case .upcoming:
            return "get-upcoming-movies"
        case .recentlyAdded:
            return "get-recently-added-movies"
        case .movie:
            return "get-movie-details"
        case .similar:
            return "get-similar-movies"
        case .moviesByTitle:
            return "get-movies-by-title"
        case .movieImages:
            return "get-movies-images-by-imdb"
        case .movieAliases:
            return "get-movies-aliases-by-imdb"
        }
    }
}
