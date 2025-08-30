import Common
import GoogleAPITokenManager
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime

extension Client {
    enum Error: Swift.Error {
        case invalidResponse(statusCode: Int)
    }
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

