import SwiftUI
internal import Combine

@MainActor
final class PhotoRowViewModel: ObservableObject {
    enum Phase {
        case idle
        case loading
        case loaded(Image)
        case failed
    }

    @Published private(set) var phase: Phase = .idle

    private let row: PhotoRow
    private let pipeline: ImagePipeline
    private var loadTask: Task<Void, Never>?

    init(row: PhotoRow, pipeline: ImagePipeline) {
        self.row = row
        self.pipeline = pipeline
    }

    func onAppear() {
        guard loadTask == nil else { return }

        loadTask = Task { [pipeline, row] in
            phase = .loading

            do {
                let uiImage = try await pipeline.image(for: row.imageURL, isVisible: true)
                try Task.checkCancellation()
                phase = .loaded(Image(uiImage: uiImage))
            } catch is CancellationError {
                await pipeline.setVisibility(false, for: row.imageURL)
            } catch {
                phase = .failed
            }

            loadTask = nil
        }
    }

    func onDisappear() {
        loadTask?.cancel()
        loadTask = nil

        Task { [pipeline, row] in
            await pipeline.setVisibility(false, for: row.imageURL)
        }
    }
}
