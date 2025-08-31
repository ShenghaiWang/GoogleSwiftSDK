import Common
import Foundation
import GoogleAPITokenManager
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime

extension Client {
    /// Initializes a Google Slides client using Service Account authentication for server-to-server communication.
    ///
    /// This initializer is designed for server applications that need to access Google Slides on behalf of users
    /// without requiring user interaction. It uses a service account JSON file for authentication.
    ///
    /// - Parameters:
    ///   - accountServiceFile: The path to the service account JSON file containing credentials
    ///   - configuration: The client configuration settings. Defaults to a new Configuration instance
    ///   - transportConfiguration: The HTTP transport configuration. Defaults to a new AsyncHTTPClientTransport.Configuration
    ///   - scopes: The OAuth 2.0 scopes to request. Defaults to Google Slides read/write permissions
    /// - Throws: An error if the service account file cannot be loaded or if initialization fails
    public init(
        accountServiceFile: String,
        configuration: Configuration = .init(),
        transportConfiguration: AsyncHTTPClientTransport.Configuration = .init(),
        scopes: [String] = ["https://www.googleapis.com/auth/presentations"],
    ) throws {
        let tokenManager = try ServiceAccountTokenManager.loadFromFile(
            accountServiceFile,
            httpClient: URLSessionHTTPClient(),
            tokenStorage: nil,
            scopes: scopes,
        )
        self.init(
            serverURL: try Servers.Server1.url(),
            configuration: configuration,
            transport: AsyncHTTPClientTransport(configuration: transportConfiguration),
            middlewares: [AuthenticationMiddleware(tokenManager: tokenManager, scopes: scopes)],
        )
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
    ) async throws -> Operations.Slides_presentations_batchUpdate.Output {
        let input = Operations.Slides_presentations_batchUpdate.Input(
            path: .init(presentationId: presentationId),
            body: .json(.init(requests: requests))
        )
        return try await slides_presentations_batchUpdate(input)
    }
}
