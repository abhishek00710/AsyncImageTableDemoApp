import Foundation

/// Stable table-row data used by the image-loading demo.
/// Every row owns a deterministic remote URL so the app can scale to 1,000 items.
struct PhotoRow: Identifiable, Hashable, Sendable {
    let id: Int
    let title: String
    let subtitle: String
    let imageURL: URL

    static func makeDemoRows(count: Int) -> [PhotoRow] {
        (0..<count).map { index in
            PhotoRow(
                id: index,
                title: "Async Image Row \(index + 1)",
                subtitle: "Downloads on demand, cancels off-screen work, and reuses cached images.",
                imageURL: URL(string: "https://picsum.photos/seed/async-image-row-\(index)/160/160")!
            )
        }
    }
}
