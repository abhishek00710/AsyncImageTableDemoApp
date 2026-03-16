import SwiftUI

@main
struct AsyncImageTableDemoApp: App {
    private let rows = PhotoRow.makeDemoRows(count: 1_000)
    private let pipeline = ImagePipeline(
        fetcher: URLSessionImageFetcher(),
        cache: MemoryImageCache(costLimitInBytes: 28 * 1_024 * 1_024)
    )

    var body: some Scene {
        WindowGroup {
            PhotoListView(rows: rows, pipeline: pipeline)
        }
    }
}
