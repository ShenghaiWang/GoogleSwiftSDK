import Common
import GoogleAPITokenManager
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime

extension Client {
    enum Error: Swift.Error {
        case invalidResponse(statusCode: Int)
    }
    /// Initializes a Google Docs client using Service Account authentication for server-to-server communication.
    ///
    /// This initializer is designed for server applications that need to access Google Docs on behalf of users
    /// without requiring user interaction. It uses a service account JSON file for authentication.
    ///
    /// - Parameters:
    ///   - accountServiceFile: The path to the service account JSON file containing credentials
    ///   - configuration: The client configuration settings. Defaults to a new Configuration instance
    ///   - transportConfiguration: The HTTP transport configuration. Defaults to a new AsyncHTTPClientTransport.Configuration
    ///   - scopes: The OAuth 2.0 scopes to request. Defaults to Google Docs read/write permissions
    /// - Throws: An error if the service account file cannot be loaded or if initialization fails
    public init(
        accountServiceFile: String,
        configuration: Configuration = .init(),
        transportConfiguration: AsyncHTTPClientTransport.Configuration = .init(),
        scopes: [String] = ["https://www.googleapis.com/auth/documents"],
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

    /// Performs a batch update operation on a Google Docs document.
    ///
    /// This method allows you to apply multiple changes to a document in a single API call.
    /// Batch updates are processed atomically, meaning either all requests succeed or all fail.
    /// This is more efficient than making individual update calls and ensures consistency.
    ///
    /// - Parameters:
    ///   - documentId: The unique identifier of the Google Docs document to update
    ///   - requests: An array of request objects defining the changes to apply to the document
    /// - Returns: The API response containing information about the batch update operation
    /// - Throws: An error if the batch update fails or if the API request is unsuccessful
    public func docs_documents_batchUpdate(
        documentId: String,
        requests: [Components.Schemas.Request],
    ) async throws -> Operations.Docs_documents_batchUpdate.Output {
        let input = Operations.Docs_documents_batchUpdate.Input(
            path: .init(documentId: documentId),
            body: .json(.init(requests: requests))
        )
        return try await docs_documents_batchUpdate(input)
    }

    /// Retrieves a Google Docs document by its ID.
    ///
    /// This method fetches the complete document structure including content, formatting,
    /// and metadata. The returned document object contains all the information needed
    /// to read or further manipulate the document.
    ///
    /// - Parameter documentId: The unique identifier of the Google Docs document to retrieve
    /// - Returns: A Document object containing the complete document structure and content
    /// - Throws: An error if the document cannot be retrieved, if access is denied, or if the document doesn't exist
    public func docs_documents_get(
        documentId: String,
    ) async throws -> Components.Schemas.Document {
        switch try await docs_documents_get(.init(path: .init(documentId: documentId))) {
        case let .ok(value):
            switch value.body {
            case let .json(document): document
            }
        case let .undocumented(statusCode: code, _):
            throw Error.invalidResponse(statusCode: code)
        }
    }
}

