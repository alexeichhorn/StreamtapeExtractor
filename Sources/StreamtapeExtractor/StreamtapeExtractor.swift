import Foundation

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
public class StreamtapeExtractor {
    
    static let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.71 Safari/537.36"
    
    enum ExtractionError: Error {
        case htmlDecodingError
    }
    
    class func extractRedirectURL(fromHTML html: String) -> URL? {
        return nil
    }
    
    public class func extract(fromHTML html: String) async throws -> URL {
        fatalError()
    }
    
    public class func extract(fromURL url: URL) async throws -> URL {
        
        var request = URLRequest(url: url)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let htmlContent = String(data: data, encoding: .utf8) else {
            throw ExtractionError.htmlDecodingError
        }
        
        return try await extract(fromHTML: htmlContent)
    }
    
}
