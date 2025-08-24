import Foundation

struct MovieDetail: Decodable, Hashable {
    let id: String
    let title: String
    let overview: String?
    let year: String?
    let rating: Double?
    let genres: [String]?
    let poster: URL?
    let releaseDate: String?
    let runtime: String?
    let director: String?
    let cast: [String]?
    let youtubeTrailerKey: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "imdb_id"
        case title
        case overview = "description"
        case year
        case rating = "imdb_rating"
        case genres
        case poster = "image_url"
        case releaseDate = "release_date"
        case runtime
        case director
        case cast = "stars"
        case youtubeTrailerKey = "youtube_trailer_key"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
        year = try container.decodeIfPresent(String.self, forKey: .year)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        // Handle runtime as both string and number
        if let runtimeInt = try? container.decodeIfPresent(Int.self, forKey: .runtime) {
            runtime = "\(runtimeInt) min"
        } else if let runtimeString = try? container.decodeIfPresent(String.self, forKey: .runtime) {
            runtime = runtimeString
        } else {
            runtime = nil
        }
        director = try container.decodeIfPresent(String.self, forKey: .director)
        
        if let ratingString = try? container.decodeIfPresent(String.self, forKey: .rating) {
            rating = Double(ratingString)
        } else {
            rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        }
        
        if let posterString = try? container.decodeIfPresent(String.self, forKey: .poster),
           !posterString.isEmpty {
            poster = URL(string: posterString)
        } else {
            poster = nil
        }
        
        // Handle genres as both array of strings and comma-separated string
        if let genresArray = try? container.decodeIfPresent([String].self, forKey: .genres) {
            genres = genresArray
        } else if let genresString = try? container.decodeIfPresent(String.self, forKey: .genres) {
            genres = genresString.components(separatedBy: ", ").filter { !$0.isEmpty }
        } else {
            genres = nil
        }
        
        // Handle cast as both array of strings and comma-separated string
        if let castArray = try? container.decodeIfPresent([String].self, forKey: .cast) {
            cast = castArray
        } else if let castString = try? container.decodeIfPresent(String.self, forKey: .cast) {
            cast = castString.components(separatedBy: ", ").filter { !$0.isEmpty }
        } else {
            cast = nil
        }
        
        // Handle YouTube trailer key
        youtubeTrailerKey = try? container.decodeIfPresent(String.self, forKey: .youtubeTrailerKey)
    }
    
    // For testing and preview purposes
    init(id: String, title: String, overview: String? = nil, year: String? = nil, rating: Double? = nil, genres: [String]? = nil, poster: URL? = nil, releaseDate: String? = nil, runtime: String? = nil, director: String? = nil, cast: [String]? = nil, youtubeTrailerKey: String? = nil) {
        self.id = id
        self.title = title
        self.overview = overview
        self.year = year
        self.rating = rating
        self.genres = genres
        self.poster = poster
        self.releaseDate = releaseDate
        self.runtime = runtime
        self.director = director
        self.cast = cast
        self.youtubeTrailerKey = youtubeTrailerKey
    }
}

// MARK: - YouTube Thumbnail Support
extension MovieDetail {
    /// YouTube thumbnail URL if trailer is available
    var youtubeThumbnailURL: URL? {
        guard let trailerKey = youtubeTrailerKey, !trailerKey.isEmpty else { return nil }
        return URL(string: "https://img.youtube.com/vi/\(trailerKey)/maxresdefault.jpg")
    }
    
    /// High quality YouTube thumbnail (fallback to medium if not available)
    var youtubeThumbnailHQURL: URL? {
        guard let trailerKey = youtubeTrailerKey, !trailerKey.isEmpty else { return nil }
        return URL(string: "https://img.youtube.com/vi/\(trailerKey)/hqdefault.jpg")
    }
    
    /// YouTube video URL for trailer
    var youtubeVideoURL: URL? {
        guard let trailerKey = youtubeTrailerKey, !trailerKey.isEmpty else { return nil }
        return URL(string: "https://www.youtube.com/watch?v=\(trailerKey)")
    }
    
    /// Check if movie has YouTube trailer
    var hasYouTubeTrailer: Bool {
        return youtubeTrailerKey != nil && !youtubeTrailerKey!.isEmpty
    }
}
