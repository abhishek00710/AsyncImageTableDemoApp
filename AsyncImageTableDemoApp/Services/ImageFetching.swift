import UIKit

protocol ImageFetching: Sendable {
    func image(for url: URL) async throws -> UIImage
}

struct URLSessionImageFetcher: ImageFetching {
    func image(for url: URL) async throws -> UIImage {
        let request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 30
        )

        let (data, _) = try await URLSession.shared.data(for: request)
        guard let image = UIImage(data: data) else {
            throw ImagePipelineError.invalidImageData
        }
        return image
    }
}
