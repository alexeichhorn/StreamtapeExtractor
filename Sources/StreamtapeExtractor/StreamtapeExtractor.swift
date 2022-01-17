import Foundation

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
public class StreamtapeExtractor {
    
    let userAgent: String
    let urlSession: StreamtapeURLSession
    
    #if !os(Linux)
    static let `default` = StreamtapeExtractor(urlSession: .default)
    #endif
    
    public init(urlSession: StreamtapeURLSession, userAgent: String = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.71 Safari/537.36") {
        self.urlSession = urlSession
        self.userAgent = userAgent
    }
    
    enum ExtractionError: Error {
        case htmlDecodingError
        case redirectURLNotFound
        case redirectTokenNotFound
        case redirectionFailed
        case disallowedAccessDetected
    }
    
    func extractRedirectURL(fromHTML html: String) throws -> URL {
        
        let urlPattern = #"<div[^>]+id="robotlink"[^>]*>\/{1,2}(?<url>[a-z]+\.[a-z]+\/[^<\n]+)<\/div>"#
        let urlRegex = try NSRegularExpression(pattern: urlPattern, options: [])
        
        guard let urlMatch = urlRegex.firstMatch(in: html, options: [], range: NSRange(location: 0, length: html.count)) else {
            throw ExtractionError.redirectURLNotFound
        }
        
        let urlMatchRange = urlMatch.range(at: 1)
        guard let urlRange = Range(urlMatchRange, in: html) else {
            throw ExtractionError.redirectURLNotFound
        }
        
        var redirectURL = "https://" + String(html[urlRange])
        
        
        // - find token replacement
        
        let tokenPattern = #"getElementById\('robotlink'\)\.innerHTML[^\n]*token=(?<token>[A-Za-z0-9-_]*)"#
        let tokenRegex = try NSRegularExpression(pattern: tokenPattern, options: [])
        
        guard let tokenMatch = tokenRegex.firstMatch(in: html, options: [], range: NSRange(location: 0, length: html.count)) else {
            throw ExtractionError.redirectTokenNotFound
        }
        
        let tokenMatchRange = tokenMatch.range(at: 1)
        guard let tokenRange = Range(tokenMatchRange, in: html) else {
            throw ExtractionError.redirectTokenNotFound
        }
        
        let token = String(html[tokenRange])
        
        
        // - replace token
        
        let oldTokenPattern = #"token=([A-Za-z0-9-_]*)"#
        let oldTokenRegex = try NSRegularExpression(pattern: oldTokenPattern, options: [])
        
        if let oldTokenMatch = oldTokenRegex.firstMatch(in: redirectURL, options: [], range: NSRange(location: 0, length: redirectURL.count)) {
            
            guard let oldTokenRange = Range(oldTokenMatch.range, in: redirectURL) else {
                throw ExtractionError.redirectTokenNotFound
            }
            let oldToken = redirectURL[oldTokenRange]
            
            redirectURL = redirectURL.replacingOccurrences(of: oldToken, with: "token=\(token)")
            
        } else {
            redirectURL += "&token=\(token)"
        }
        
        if let redirectURL = URL(string: redirectURL) {
            return redirectURL
        }
        
        throw ExtractionError.redirectURLNotFound
    }
    
    /// extracts direct video url from raw html of Streamtape video page
    /// - parameter html: HTML of video page on Streamtape
    /// - returns: video url
    public func extract(fromHTML html: String) async throws -> URL {
        
        let redirectURL = try extractRedirectURL(fromHTML: html)
        print(redirectURL)
        
        var request = StreamtapeURLSession.Request(url: redirectURL)
        request.httpMethod = "head"
        request.headers = ["User-Agent": userAgent]
        
        let response = try await urlSession.handleRequest(request)
        
        guard let url = response.url else {
            throw ExtractionError.redirectionFailed
        }
        
        guard !url.path.contains("streamtape_do_not_delete") else {
            throw ExtractionError.disallowedAccessDetected
        }
        
        return url
    }
    
    /// extracts direct video url from standard Streamtape url
    /// - parameter url: Streamtape url (e.g. https://streamtape.com/e/kLdy1xjdZktKvx1)
    /// - returns: video url
    public func extract(fromURL url: URL) async throws -> URL {
        
        var request = StreamtapeURLSession.Request(url: url)
        request.headers = ["User-Agent": userAgent]
        
        let response = try await urlSession.handleRequest(request)
        
        guard let htmlContent = String(data: response.data, encoding: .utf8) else {
            throw ExtractionError.htmlDecodingError
        }
        
        return try await extract(fromHTML: htmlContent)
    }
    
}
