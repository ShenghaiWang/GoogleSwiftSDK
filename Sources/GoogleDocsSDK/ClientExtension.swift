import Common
import GoogleAPITokenManager
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime
import Foundation

extension Client: AuthorizableClient {
    public static nonisolated var oauthScopes: [String] {
        ["https://www.googleapis.com/auth/documents"]
    }

    public static nonisolated func serverURL() throws -> URL {
        try Servers.Server1.url()
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
        let result = try await docs_documents_get(.init(path: .init(documentId: documentId)))
        return try await ResponseHandler.extractJSON(from: result)
    }
}

