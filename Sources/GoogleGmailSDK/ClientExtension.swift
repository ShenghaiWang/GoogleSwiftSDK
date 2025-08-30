import Common
import GoogleAPITokenManager
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime
import Foundation

extension Client {
    enum Error: Swift.Error {
        case invalidResponse(statusCode: Int)
    }
    public init(
        accountServiceFile: String,
        configuration: Configuration = .init(),
        transportConfiguration: AsyncHTTPClientTransport.Configuration = .init(),
        scopes: [String] = ["https://www.googleapis.com/auth/gmail.modify", "https://www.googleapis.com/auth/gmail.compose"],
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
            middlewares: [AuthenticationMiddleware(tokenManager: tokenManager)],
        )
    }

    public func gmail_users_drafts_create(
        to: [String],
        subject: String,
        body: String
    ) async throws -> Any {
        // Construct MIME message
        let toHeader = to.joined(separator: ", ")
        let mimeMessage = """
        To: \(toHeader)
        Subject: \(subject)
        Content-Type: text/plain; charset=UTF-8

        \(body)
        """
//        // Encode MIME message in base64url
//        let mimeData = mimeMessage.data(using: .utf8)!
//        var base64Encoded = mimeData.base64EncodedString()
//        base64Encoded = base64Encoded.replacingOccurrences(of: "+", with: "-")
//        base64Encoded = base64Encoded.replacingOccurrences(of: "/", with: "_")
//        base64Encoded = base64Encoded.replacingOccurrences(of: "=", with: "")
//        // Construct body as dictionary
//        let draftBody: [String: Any] = [
//            "message": ["raw": base64Encoded]
//        ]
        // Try passing the dictionary as the body
        return try await gmail_users_drafts_create(
            path: .init(userId: "me"),
            body: .messageRfc822(.init(stringLiteral: mimeMessage))
        )
    }
}
