import Foundation
import Observation

@Observable
final class DogStore {
    private(set) var imageURLs: [URL] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private var activeRequestID = UUID()

    func loadImages(for breed: DogBreed) async {
        let requestID = UUID()
        activeRequestID = requestID
        imageURLs = []
        errorMessage = nil
        isLoading = true

        do {
            let (data, response) = try await URLSession.shared.data(
                from: breed.imageListURL
            )

            try Task.checkCancellation()

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw DogAPIError.invalidResponse
            }

            let result = try JSONDecoder().decode(DogImagesResponse.self, from: data)

            guard result.status == "success" else {
                throw DogAPIError.unsuccessfulStatus
            }

            try Task.checkCancellation()
            guard activeRequestID == requestID else { return }

            imageURLs = result.message
            isLoading = false
        } catch is CancellationError {
            // A new selection starts a new task. Ignore the cancelled request.
        } catch {
            guard activeRequestID == requestID else { return }
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

private struct DogImagesResponse: Decodable {
    let message: [URL]
    let status: String
}

private enum DogAPIError: LocalizedError {
    case invalidResponse
    case unsuccessfulStatus

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "The Dog API returned an invalid response."
        case .unsuccessfulStatus:
            "The Dog API could not load images for this breed."
        }
    }
}
