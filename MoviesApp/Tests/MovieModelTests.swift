import XCTest
@testable import MoviesApp

final class MovieModelTests: XCTestCase {
    
    func testMovieDecoding() throws {
        let json = """
        {
            "imdb_id": "tt0111161",
            "title": "The Shawshank Redemption",
            "year": "1994",
            "imdb_rating": "9.3",
            "image_url": "https://example.com/poster.jpg"
        }
        """.data(using: .utf8)!
        
        let movie = try JSONDecoder().decode(Movie.self, from: json)
        
        XCTAssertEqual(movie.id, "tt0111161")
        XCTAssertEqual(movie.title, "The Shawshank Redemption")
        XCTAssertEqual(movie.year, "1994")
        XCTAssertEqual(movie.rating, 9.3)
        XCTAssertEqual(movie.poster?.absoluteString, "https://example.com/poster.jpg")
    }
    
    func testMovieDecodingWithMissingFields() throws {
        let json = """
        {
            "imdb_id": "tt0111161",
            "title": "The Shawshank Redemption"
        }
        """.data(using: .utf8)!
        
        let movie = try JSONDecoder().decode(Movie.self, from: json)
        
        XCTAssertEqual(movie.id, "tt0111161")
        XCTAssertEqual(movie.title, "The Shawshank Redemption")
        XCTAssertNil(movie.year)
        XCTAssertNil(movie.rating)
        XCTAssertNil(movie.poster)
    }
    
    func testMovieDetailDecoding() throws {
        let json = """
        {
            "imdb_id": "tt0111161",
            "title": "The Shawshank Redemption",
            "description": "Two imprisoned men bond over a number of years...",
            "year": "1994",
            "imdb_rating": "9.3",
            "genres": ["Drama"],
            "image_url": "https://example.com/poster.jpg",
            "release_date": "1994-09-23",
            "runtime": "142 min",
            "director": "Frank Darabont",
            "stars": ["Tim Robbins", "Morgan Freeman"]
        }
        """.data(using: .utf8)!
        
        let movieDetail = try JSONDecoder().decode(MovieDetail.self, from: json)
        
        XCTAssertEqual(movieDetail.id, "tt0111161")
        XCTAssertEqual(movieDetail.title, "The Shawshank Redemption")
        XCTAssertEqual(movieDetail.overview, "Two imprisoned men bond over a number of years...")
        XCTAssertEqual(movieDetail.year, "1994")
        XCTAssertEqual(movieDetail.rating, 9.3)
        XCTAssertEqual(movieDetail.genres, ["Drama"])
        XCTAssertEqual(movieDetail.runtime, "142 min")
        XCTAssertEqual(movieDetail.director, "Frank Darabont")
        XCTAssertEqual(movieDetail.cast, ["Tim Robbins", "Morgan Freeman"])
    }
    
    func testMoviesResponseDecoding() throws {
        let json = """
        {
            "movie_results": [
                {
                    "imdb_id": "tt0111161",
                    "title": "The Shawshank Redemption",
                    "year": "1994",
                    "imdb_rating": "9.3"
                }
            ]
        }
        """.data(using: .utf8)!
        
        let response = try JSONDecoder().decode(MoviesResponse.self, from: json)
        
        XCTAssertEqual(response.movies.count, 1)
        XCTAssertEqual(response.movies.first?.title, "The Shawshank Redemption")
    }
}
