import XCTest
@testable import MoviesApp

final class TrendingViewModelTests: XCTestCase {
    
    func testInitialState() {
        let vm = TrendingViewModel(service: MockMoviesService())
        XCTAssertTrue(vm.items.isEmpty)
        XCTAssertTrue(vm.filteredItems.isEmpty)
    }
    
    func testSearchFiltering() {
        let vm = TrendingViewModel(service: MockMoviesService())
        
        let movies = [
            Movie(id: "1", title: "The Matrix", year: "1999"),
            Movie(id: "2", title: "Inception", year: "2010"),
            Movie(id: "3", title: "Matrix Reloaded", year: "2003")
        ]
        
        vm.items = movies
        vm.filteredItems = movies
        
        vm.search(query: "Matrix")
        XCTAssertEqual(vm.filteredItems.count, 2)
        XCTAssertTrue(vm.filteredItems.contains { $0.title == "The Matrix" })
        XCTAssertTrue(vm.filteredItems.contains { $0.title == "Matrix Reloaded" })
        
        vm.search(query: "")
        XCTAssertEqual(vm.filteredItems.count, 3)
        
        vm.search(query: "1999")
        XCTAssertEqual(vm.filteredItems.count, 1)
        XCTAssertEqual(vm.filteredItems.first?.title, "The Matrix")
    }
    
    func testShouldLoadMore() {
        let vm = TrendingViewModel(service: MockMoviesService())
        
        vm.filteredItems = Array(repeating: Movie(id: "1", title: "Test"), count: 10)
        
        XCTAssertTrue(vm.shouldLoadMore(for: 5))
        XCTAssertTrue(vm.shouldLoadMore(for: 6))
        
        XCTAssertFalse(vm.shouldLoadMore(for: 0))
        XCTAssertFalse(vm.shouldLoadMore(for: 1))
    }
}

final class MockMoviesService: MoviesServiceProtocol {
    
    var shouldFail = false
    var mockMovies: [Movie] = []
    var mockMovieDetail: MovieDetail?
    
    func getTrending(page: Int) async throws -> [Movie] {
        if shouldFail {
            throw HTTPError.server(500)
        }
        return mockMovies
    }
    
    func getNowPlaying(page: Int) async throws -> [Movie] {
        if shouldFail {
            throw HTTPError.server(500)
        }
        return mockMovies
    }
    
    func getUpcoming(page: Int) async throws -> [Movie] {
        if shouldFail {
            throw HTTPError.server(500)
        }
        return mockMovies
    }
    
    func getMovie(id: String) async throws -> MovieDetail {
        if shouldFail {
            throw HTTPError.server(500)
        }
        return mockMovieDetail ?? MovieDetail(id: id, title: "Mock Movie")
    }
    
    func getSimilar(id: String, page: Int) async throws -> [Movie] {
        if shouldFail {
            throw HTTPError.server(500)
        }
        return mockMovies
    }
}
