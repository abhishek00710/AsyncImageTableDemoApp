import Foundation

enum ImagePipelineError: LocalizedError {
    case invalidImageData

    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "The server response did not contain a valid image."
        }
    }
}
