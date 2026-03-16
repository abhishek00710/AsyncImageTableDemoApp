import SwiftUI

struct PhotoListView: View {
    let rows: [PhotoRow]
    let pipeline: ImagePipeline

    @State private var cacheSummary = "Visible cache: 0 • Cached: 0 • Memory: 0 KB"

    var body: some View {
        NavigationStack {
            List(rows) { row in
                PhotoRowView(row: row, pipeline: pipeline)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(backgroundGradient)
            .navigationTitle("Async Image Table")
            .navigationBarTitleDisplayMode(.large)
            .safeAreaInset(edge: .top) {
                headerCard
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .background(.clear)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(cacheSummary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .task {
            await updateCacheSummaryLoop()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
            Task {
                await pipeline.handleMemoryWarning()
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("1,000 SwiftUI rows")
                .font(.headline)
            Text("Images are loaded only when rows appear on screen. Off-screen work is cancelled, cached images are reused, and non-visible images are trimmed when memory pressure grows.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.97, green: 0.97, blue: 0.95),
                Color(red: 0.94, green: 0.96, blue: 0.99)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private func updateCacheSummaryLoop() async {
        while !Task.isCancelled {
            let snapshot = await pipeline.cacheSnapshot()
            cacheSummary = "Visible cache: \(snapshot.visibleItemCount) • Cached: \(snapshot.cachedItemCount) • Memory: \(ByteCountFormatter.string(fromByteCount: Int64(snapshot.totalCostInBytes), countStyle: .memory))"
            try? await Task.sleep(for: .seconds(1))
        }
    }
}
