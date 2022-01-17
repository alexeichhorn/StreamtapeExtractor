# StreamtapeExtractor

Extracts raw video urls from any streamtape.com video.

## Usage
Get video path from streamtape url:
```swift
let url = URL(string: "https://streamtape.com/e/kLdy1xjdZktKvx1")!
let videoURL = try await StreamtapeExtractor.extract(fromURL: url)
// do stuff with retrieved videoURL
```

