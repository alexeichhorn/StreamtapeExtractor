import XCTest
@testable import StreamtapeExtractor

final class StreamtapeExtractorTests: XCTestCase {
    
    func testSourceURL(_ videoURL: URL) async throws -> URL {
        return try await StreamtapeExtractor.default.extract(fromURL: videoURL)
    }
    
    func testUnavailableURL() async {
        let unavailableURL = URL(string: "https://streamtape.com/e/kLdy3ajlZktOvx1")!
        do {
            let url = try await testSourceURL(unavailableURL)
            XCTFail("didn't throw. Returned \(url)")
        } catch {
            return
        }
    }
    
    func testBunnyVideo() async throws {
        let url = try await testSourceURL(URL(string: "https://streamtape.com/e/kLdy1xjlZktOvx1")!)
        
        XCTAssert(url.path.hasSuffix(".mp4"))
        XCTAssertFalse(url.path.contains("do_not_delete"))
        
        print("extracted \(url) for bunny video")
    }
    
    func testHTMLExtraction() throws {
        let html = """
        <div class="plyr-container">
            <div class="plyr-overlay"></div>
            <video crossorigin="anonymous" id="mainvideo" width="100%" height="100%"
            poster="https://thumb.tapecontent.net/thumb/kLdy1xjlZktOvx1/PkV0mBVqK3C0JZK.jpg"
            playsinline preload="metadata"></video>
            <script>
                if (navigator.userAgent.indexOf("TV") == -1) {
                    window.player = new Plyr("video");
                } else {
                    document.getElementById("mainvideo").setAttribute("controls", "controls");
                    window.procsubs();
                }
            </script>
        </div>
        <div id="ideoolink" style="display:none;">/streamtape.com/get_video?id=kLdy1xjlZktOvx1&expires=1642504822&ip=GxMsD0SQKxSHDN&token=0Dre-3bspcde</div>
        <div
        id="robotlink" style="display:none;">/streamtape.com/get_video?id=kLdy1xjlZktOvx1&expires=1642504822&ip=GxMsD0SQKxSHDN&token=0Dre-3bspcde</div>
            <script>
                document.getElementById('ideoolink').innerHTML = "/streamtape.com/get_video?id=k" + '' + ('xcdbLdy1xjlZktOvx1&expires=1642504822&ip=GxMsD0SQKxSHDN&token=0Dre-3bspk48').substring(1).substring(2);
                document.getElementById('ideoolink').innerHTML = "//streamtape.com/get_video?id=" + '' + ('xnftbLdy1xjlZktOvx1&expires=1642504822&ip=GxMsD0SQKxSHDN&token=0Dre-3bspk48').substring(3).substring(1);
                document.getElementById('robotlink').innerHTML = '//streamtape.com/get_video?id=' + ('xcdkLdy1xjlZktOvx1&expires=1642504822&ip=GxMsD0SQKxSHDN&token=0Dre-3bspk48').substring(2).substring(1);
            </script>
        """
        
        let url = try StreamtapeExtractor.default.extractRedirectURL(fromHTML: html)
        
        XCTAssertEqual(url, URL(string: "https://streamtape.com/get_video?id=kLdy1xjlZktOvx1&expires=1642504822&ip=GxMsD0SQKxSHDN&token=0Dre-3bspk48")!)
    }
    
    
    static var allTests = [
        ("testUnavailableURL", testUnavailableURL),
        ("testBunnyVideo", testBunnyVideo),
        ("testHTMLExtraction", testHTMLExtraction)
    ]
    
}
