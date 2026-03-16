import UIKit

/// Central image-loading actor that deduplicates in-flight downloads, serves
/// cached images immediately, and coordinates cache visibility with the UI.
actor ImagePipeline {
    private let fetcher: ImageFetching
    private let cache: MemoryImageCache
    private var inFlightTasks: [URL: Task<UIImage, Error>] = [:]

    init(fetcher: ImageFetching, cache: MemoryImageCache) {
        self.fetcher = fetcher
        self.cache = cache
    }

    func image(for url: URL, isVisible: Bool) async throws -> UIImage {
        await cache.setVisibility(isVisible: isVisible, for: url)

        if let cached = await cache.image(for: url) {
            return cached
        }

        if let inFlightTask = inFlightTasks[url] {
            return try await inFlightTask.value
        }

        let task = Task { [fetcher, cache] in
            let image = try await fetcher.image(for: url)
            await cache.insert(image, for: url)
            return image
        }

        inFlightTasks[url] = task

        do {
            let image = try await task.value
            inFlightTasks[url] = nil
            return image
        } catch {
            inFlightTasks[url] = nil
            throw error
        }
    }

    func setVisibility(_ isVisible: Bool, for url: URL) async {
        await cache.setVisibility(isVisible: isVisible, for: url)
    }

    func handleMemoryWarning() async {
        await cache.handleMemoryWarning()
    }

    func cacheSnapshot() async -> MemoryImageCache.Snapshot {
        await cache.snapshot()
    }
}
