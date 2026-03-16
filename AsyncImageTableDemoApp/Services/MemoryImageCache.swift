import UIKit

/// Actor-backed in-memory cache with visibility-aware eviction.
/// Visible images are protected while they are on screen; non-visible images are
/// evicted first when memory grows beyond the configured budget.
actor MemoryImageCache {
    struct Snapshot: Sendable {
        let totalCostInBytes: Int
        let visibleItemCount: Int
        let cachedItemCount: Int
    }

    private struct Entry {
        let image: UIImage
        let costInBytes: Int
        var lastAccess: UInt64
        var isVisible: Bool
    }

    private var entries: [URL: Entry] = [:]
    private var visibleURLs: Set<URL> = []
    private var accessClock: UInt64 = 0
    private(set) var totalCostInBytes = 0
    private let costLimitInBytes: Int
    private let trimTargetInBytes: Int

    init(costLimitInBytes: Int) {
        self.costLimitInBytes = costLimitInBytes
        self.trimTargetInBytes = Int(Double(costLimitInBytes) * 0.7)
    }

    func image(for url: URL) -> UIImage? {
        guard var entry = entries[url] else { return nil }
        entry.lastAccess = nextAccessTick()
        entries[url] = entry
        return entry.image
    }

    func insert(_ image: UIImage, for url: URL) {
        let cost = Self.cost(for: image)

        if let existing = entries.removeValue(forKey: url) {
            totalCostInBytes -= existing.costInBytes
        }

        entries[url] = Entry(
            image: image,
            costInBytes: cost,
            lastAccess: nextAccessTick(),
            isVisible: visibleURLs.contains(url)
        )
        totalCostInBytes += cost

        trimIfNeeded(target: trimTargetInBytes)
    }

    func setVisibility(isVisible: Bool, for url: URL) {
        if isVisible {
            visibleURLs.insert(url)
        } else {
            visibleURLs.remove(url)
        }

        guard var entry = entries[url] else { return }
        entry.isVisible = isVisible
        entry.lastAccess = nextAccessTick()
        entries[url] = entry

        if !isVisible {
            trimIfNeeded(target: trimTargetInBytes)
        }
    }

    func handleMemoryWarning() {
        trimIfNeeded(target: costLimitInBytes / 2)
    }

    func snapshot() -> Snapshot {
        Snapshot(
            totalCostInBytes: totalCostInBytes,
            visibleItemCount: entries.values.filter(\.isVisible).count,
            cachedItemCount: entries.count
        )
    }

    private func trimIfNeeded(target: Int) {
        guard totalCostInBytes > target else { return }

        let evictionCandidates = entries
            .filter { !$0.value.isVisible }
            .sorted { $0.value.lastAccess < $1.value.lastAccess }

        for candidate in evictionCandidates where totalCostInBytes > target {
            guard let removed = entries.removeValue(forKey: candidate.key) else { continue }
            totalCostInBytes -= removed.costInBytes
        }
    }

    private func nextAccessTick() -> UInt64 {
        accessClock += 1
        return accessClock
    }

    private static func cost(for image: UIImage) -> Int {
        if let cgImage = image.cgImage {
            return cgImage.bytesPerRow * cgImage.height
        }

        let scale = image.scale
        let width = image.size.width * scale
        let height = image.size.height * scale
        return Int(width * height * 4)
    }
}
