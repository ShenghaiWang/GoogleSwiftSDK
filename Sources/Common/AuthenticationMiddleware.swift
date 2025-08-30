import Foundation
import GoogleAPITokenManager
import HTTPTypes
import OpenAPIRuntime

public struct AuthenticationMiddleware: ClientMiddleware {
    let tokenManager: any TokenManager
    let scopes: [String]

    public init(tokenManager: any TokenManager, scopes: [String]) {
        self.tokenManager = tokenManager
        self.scopes = scopes
    }

    public func intercept(
        _ request: HTTPTypes.HTTPRequest,
        body: OpenAPIRuntime.HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPTypes.HTTPRequest, OpenAPIRuntime.HTTPBody?, URL) async throws -> (
            HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?
        )
    ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {
        var request = request
        let token = try await tokenManager.authenticate(scopes: scopes)
        request.headerFields.append(.init(name: .authorization, value: "Bearer \(token.accessToken)"))
        return try await next(request, body, baseURL)
    }
}
