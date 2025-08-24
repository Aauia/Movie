import Foundation

enum HTTPError: Error {
    case badURL
    case noData
    case decoding
    case server(Int)
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .badURL:
            return "Неверный URL"
        case .noData:
            return "Нет данных"
        case .decoding:
            return "Ошибка декодирования данных"
        case .server(let code):
            return "Ошибка сервера: \(code)"
        case .unknown:
            return "Неизвестная ошибка"
        }
    }
}

final class APIClient {
    private let session: URLSession
    private let apiKey: String
    private let apiHost: String
    
    init(session: URLSession = .shared) {
        self.session = session
        
        let apiKeyFromPlist = Bundle.main.object(forInfoDictionaryKey: "RAPID_API_KEY") as? String ?? ""
        let apiHostFromPlist = Bundle.main.object(forInfoDictionaryKey: "RAPID_API_HOST") as? String ?? ""
        
        if apiKeyFromPlist.isEmpty || apiKeyFromPlist == "$(RAPID_API_KEY)" {
            self.apiKey = "KEY"
            self.apiHost = "movies-tv-shows-database.p.rapidapi.com"
            #if DEBUG
            print("⚠️ Using hardcoded API key. Please set up xcconfig properly!")
            #endif
        } else {
            self.apiKey = apiKeyFromPlist
            self.apiHost = apiHostFromPlist.isEmpty ? "movies-tv-shows-database.p.rapidapi.com" : apiHostFromPlist
            #if DEBUG
            print("✅ API key loaded from xcconfig")
            #endif
        }
    }
    
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = endpoint.httpMethod
        request.setValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue(apiHost, forHTTPHeaderField: "x-rapidapi-host")
        request.setValue(endpoint.typeHeader, forHTTPHeaderField: "Type")
        
        #if DEBUG
        print("🌐 API Request: \(endpoint.typeHeader) - Page \((endpoint.url.query?.contains("page=") == true) ? String(endpoint.url.query?.split(separator: "=").last ?? "?") : "N/A")")
        #endif
        
        do {
            let (data, response) = try await session.data(for: request)
            
            #if DEBUG
            print("📦 Response: \(data.count) bytes")
            #endif
            
            if let httpResponse = response as? HTTPURLResponse {
                #if DEBUG
                print("📊 HTTP Status: \(httpResponse.statusCode)")
                #endif
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    #if DEBUG
                    print("❌ HTTP Error: \(httpResponse.statusCode)")
                    if let errorString = String(data: data, encoding: .utf8) {
                        print("❌ Error Response: \(errorString)")
                    }
                    #endif
                    throw HTTPError.server(httpResponse.statusCode)
                }
            }
            
            if data.count == 0 {
                print("⚠️ Received empty response from API")
                print("💡 This might indicate:")
                print("   - API is returning empty data set")
                print("   - API endpoint might be deprecated")
                print("   - Subscription might not include this endpoint")
                print("   - API might be experiencing issues")
                
                print("⚠️ Note: Using recently-added-movies endpoint which should start from page 2")
                throw HTTPError.noData
            }
            
            let decoder = JSONDecoder()
            
            decoder.dateDecodingStrategy = .iso8601
            
            return try decoder.decode(T.self, from: data)
        } catch let error as DecodingError {
            #if DEBUG
            print("❌ Decoding error: \(error)")
            
            switch error {
            case .keyNotFound(let key, let context):
                print("❌ Missing key '\(key.stringValue)' in \(context.debugDescription)")
            case .typeMismatch(let type, let context):
                print("❌ Type mismatch for type '\(type)' in \(context.debugDescription)")
            case .valueNotFound(let type, let context):
                print("❌ Value not found for type '\(type)' in \(context.debugDescription)")
            case .dataCorrupted(let context):
                print("❌ Data corrupted: \(context.debugDescription)")
            @unknown default:
                print("❌ Unknown decoding error: \(error)")
            }
            #endif
            
            throw HTTPError.decoding
        } catch let error as HTTPError {
            #if DEBUG
            print("❌ HTTP error: \(error)")
            #endif
            throw error
        } catch {
            #if DEBUG
            print("❌ Network error: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            #endif
            throw HTTPError.unknown
        }
    }
}
