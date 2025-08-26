import Foundation
import OpenAPIRuntime
import HTTPTypes
import GoogleAPITokenManager

public struct AuthenticationMiddleware: ClientMiddleware {
    let tokenManager: any TokenManager

    public init(tokenManager: any TokenManager) {
        self.tokenManager = tokenManager
    }

    public func intercept(
        _ request: HTTPTypes.HTTPRequest,
        body: OpenAPIRuntime.HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPTypes.HTTPRequest, OpenAPIRuntime.HTTPBody?, URL) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?)) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {
            var request = request
            let token = try await tokenManager.getAccessToken()
            request.headerFields.append(.init(name: .authorization, value: "Bearer \(token)"))
            return try await next(request, body, baseURL)
        }
}
