import Foundation

protocol MoviesServiceProtocol {
    func getTrending(page: Int) async throws -> [Movie]
    func getNowPlaying(page: Int) async throws -> [Movie]
    func getUpcoming(page: Int) async throws -> [Movie]
    func getMovie(id: String) async throws -> MovieDetail
    func getSimilar(id: String, page: Int) async throws -> [Movie]
    func getRecentlyAdded(page: Int) async throws -> [Movie]
    func getMoviesByTitle(title: String, page: Int) async throws -> [Movie]
    func getMovieImages(imdbId: String) async throws -> MovieImages
    func getMovieAliases(imdbId: String) async throws -> MovieAliases
}

final class MoviesService: MoviesServiceProtocol {
    private let api: APIClient
    
    init(api: APIClient = APIClient()) {
        self.api = api
    }
    
    func getTrending(page: Int) async throws -> [Movie] {
        do {
            let response: MoviesResponse = try await api.request(.trending(page: page))
            return response.movies
        } catch {
            let movies: [Movie] = try await api.request(.trending(page: page))
            return movies
        }
    }
    
    func getNowPlaying(page: Int) async throws -> [Movie] {
        do {
            let response: MoviesResponse = try await api.request(.nowPlaying(page: page))
            return response.movies
        } catch {
            let movies: [Movie] = try await api.request(.nowPlaying(page: page))
            return movies
        }
    }
    
    func getUpcoming(page: Int) async throws -> [Movie] {
        do {
            let response: MoviesResponse = try await api.request(.upcoming(page: page))
            return response.movies
        } catch {
            let movies: [Movie] = try await api.request(.upcoming(page: page))
            return movies
        }
    }
    
    func getMovie(id: String) async throws -> MovieDetail {
        return try await api.request(.movie(id: id))
    }
    
    func getSimilar(id: String, page: Int) async throws -> [Movie] {
        print("🔍 Fetching similar movies for ID: \(id), page: \(page)")
        do {
            let response: MoviesResponse = try await api.request(.similar(id: id, page: page))
            print("✅ Similar movies response: \(response.movies.count) movies")
            return response.movies
        } catch {
            print("❌ Similar movies response failed, trying direct array decode: \(error)")
            do {
                let movies: [Movie] = try await api.request(.similar(id: id, page: page))
                print("✅ Similar movies direct decode: \(movies.count) movies")
                return movies
            } catch {
                print("⚠️ Similar movies endpoint completely failed, using trending as fallback")
                let trending: [Movie] = try await getTrending(page: page)
                print("🔄 Using trending movies as fallback: \(trending.count) movies")
                return trending
            }
        }
    }
    
    func getRecentlyAdded(page: Int) async throws -> [Movie] {
        do {
            let response: MoviesResponse = try await api.request(.recentlyAdded(page: page))
            return response.movies
        } catch {
            let movies: [Movie] = try await api.request(.recentlyAdded(page: page))
            return movies
        }
    }
    
    func getMoviesByTitle(title: String, page: Int) async throws -> [Movie] {
        do {
            let response: MoviesResponse = try await api.request(.moviesByTitle(title: title, page: page))
            return response.movies
        } catch {
            let movies: [Movie] = try await api.request(.moviesByTitle(title: title, page: page))
            return movies
        }
    }
    
    func getMovieImages(imdbId: String) async throws -> MovieImages {
        return try await api.request(.movieImages(imdbId: imdbId))
    }
    
    func getMovieAliases(imdbId: String) async throws -> MovieAliases {
        return try await api.request(.movieAliases(imdbId: imdbId))
    }
}
