import Foundation

struct Movie: Decodable, Hashable {
    let id: String
    let title: String
    let year: String?
    let rating: Double?
    let poster: URL?
    
    private enum CodingKeys: String, CodingKey {
        case id = "imdb_id"
        case title
        case year
        case rating = "imdb_rating"
        case poster = "image_url"
        case altId = "id"
        case altRating = "rating" 
        case altPoster = "poster_path"
        case altPoster2 = "poster"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let imdbId = try? container.decodeIfPresent(String.self, forKey: .id), !imdbId.isEmpty {
            id = imdbId
        } else if let altId = try? container.decodeIfPresent(String.self, forKey: .altId), !altId.isEmpty {
            id = altId
        } else {
            throw DecodingError.keyNotFound(CodingKeys.id, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No valid ID found"))
        }
        
        title = try container.decode(String.self, forKey: .title)
        year = try container.decodeIfPresent(String.self, forKey: .year)
        
        if let ratingString = try? container.decodeIfPresent(String.self, forKey: .rating), !ratingString.isEmpty {
            rating = Double(ratingString)
        } else if let ratingDouble = try? container.decodeIfPresent(Double.self, forKey: .rating) {
            rating = ratingDouble
        } else if let altRatingString = try? container.decodeIfPresent(String.self, forKey: .altRating), !altRatingString.isEmpty {
            rating = Double(altRatingString)
        } else if let altRatingDouble = try? container.decodeIfPresent(Double.self, forKey: .altRating) {
            rating = altRatingDouble
        } else {
            rating = nil
        }
        
        if let posterString = try? container.decodeIfPresent(String.self, forKey: .poster), !posterString.isEmpty {
            poster = URL(string: posterString)
        } else if let altPosterString = try? container.decodeIfPresent(String.self, forKey: .altPoster), !altPosterString.isEmpty {
            poster = URL(string: altPosterString)
        } else if let altPoster2String = try? container.decodeIfPresent(String.self, forKey: .altPoster2), !altPoster2String.isEmpty {
            poster = URL(string: altPoster2String)
        } else {
            poster = nil
        }
    }
    
    init(id: String, title: String, year: String? = nil, rating: Double? = nil, poster: URL? = nil) {
        self.id = id
        self.title = title
        self.year = year
        self.rating = rating
        self.poster = poster
    }
}

struct MoviesResponse: Decodable {
    let movies: [Movie]
    let totalResults: Int?
    let totalPages: Int?
    let page: Int?
    
    private enum CodingKeys: String, CodingKey {
        case movies = "movie_results"
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case page
        case results = "results"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let movieResults = try? container.decodeIfPresent([Movie].self, forKey: .movies) {
            movies = movieResults
        } else if let results = try? container.decodeIfPresent([Movie].self, forKey: .results) {
            movies = results
        } else {
            do {
                let singleContainer = try decoder.singleValueContainer()
                movies = try singleContainer.decode([Movie].self)
            } catch {
                movies = []
            }
        }
        
        totalResults = try? container.decodeIfPresent(Int.self, forKey: .totalResults)
        totalPages = try? container.decodeIfPresent(Int.self, forKey: .totalPages)
        page = try? container.decodeIfPresent(Int.self, forKey: .page)
    }
    
    init(movies: [Movie], totalResults: Int?, totalPages: Int?, page: Int?) {
        self.movies = movies
        self.totalResults = totalResults
        self.totalPages = totalPages
        self.page = page
    }
}

struct MovieImages: Decodable {
    let images: [String]
    
    private enum CodingKeys: String, CodingKey {
        case images = "image_urls"
        case altImages = "images"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let imageUrls = try? container.decodeIfPresent([String].self, forKey: .images) {
            images = imageUrls
        } else if let altImageUrls = try? container.decodeIfPresent([String].self, forKey: .altImages) {
            images = altImageUrls
        } else {
            images = []
        }
    }
}

struct MovieAliases: Decodable {
    let aliases: [String]
    
    private enum CodingKeys: String, CodingKey {
        case aliases
        case altAliases = "titles"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let aliasesArray = try? container.decodeIfPresent([String].self, forKey: .aliases) {
            aliases = aliasesArray
        } else if let altAliasesArray = try? container.decodeIfPresent([String].self, forKey: .altAliases) {
            aliases = altAliasesArray
        } else {
            aliases = []
        }
    }
}
