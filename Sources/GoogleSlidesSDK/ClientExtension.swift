import Common
import Foundation
import GoogleAPITokenManager
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime

extension Client {
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
