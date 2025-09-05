import Common
import Foundation
import GoogleAPITokenManager
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime

extension Client: AuthorizableClient {
    public static nonisolated var oauthScopes: [String] {
        ["https://www.googleapis.com/auth/presentations"]
    }

    public static nonisolated func serverURL() throws -> URL {
        try Servers.Server1.url()
    }

    /// Performs a batch update operation on a Google Slides presentation.
    ///
    /// This method allows you to apply multiple changes to a presentation in a single API call.
    /// Batch updates are processed atomically, meaning either all requests succeed or all fail.
    /// This is more efficient than making individual update calls and ensures consistency across
    /// all modifications to slides, text, images, and other presentation elements.
    ///
    /// - Parameters:
    ///   - presentationId: The unique identifier of the Google Slides presentation to update
    ///   - requests: An array of request objects defining the changes to apply to the presentation
    /// - Returns: The API response containing information about the batch update operation
    /// - Throws: An error if the batch update fails or if the API request is unsuccessful
    public func slides_presentations_batchUpdate(
        presentationId: String,
        requests: [Components.Schemas.Request]
    ) async throws -> Components.Schemas.BatchUpdatePresentationResponse {
        let input = Operations.Slides_presentations_batchUpdate.Input(
            path: .init(presentationId: presentationId),
            body: .json(.init(requests: requests))
        )
        let result = try await slides_presentations_batchUpdate(input)
        return try await ResponseHandler.extractJSON(from: result)
    }
}
