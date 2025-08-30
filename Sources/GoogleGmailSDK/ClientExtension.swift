import Common
import GoogleAPITokenManager
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime
import Foundation

extension Client {
    enum Error: Swift.Error {
        case invalidResponse(statusCode: Int)
    }
    
    // Service Account Authentication (for server-to-server)
    public init(
        accountServiceFile: String,
        configuration: Configuration = .init(),
        transportConfiguration: AsyncHTTPClientTransport.Configuration = .init(),
        scopes: [String] = ["https://www.googleapis.com/auth/gmail.modify"],
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
    
    // OAuth 2.0 Authentication (for personal accounts)
    public init(
        clientId: String,
        clientSecret: String,
        redirectURI: String = "http://localhost", // For desktop apps
        configuration: Configuration = .init(),
        transportConfiguration: AsyncHTTPClientTransport.Configuration = .init(),
        scopes: [String] = ["https://www.googleapis.com/auth/gmail.modify"],
        tokenStorage: (any TokenStorage)? = InMemoeryTokenStorage()
    ) throws {
        let tokenManager = GoogleOAuth2TokenManager(
            clientId: clientId,
            clientSecret: clientSecret,
            redirectURI: redirectURI,
            tokenStorage: tokenStorage,
            httpClient: URLSessionHTTPClient()
        )
        self.init(
            serverURL: try Servers.Server1.url(),
            configuration: configuration,
            transport: AsyncHTTPClientTransport(configuration: transportConfiguration),
            middlewares: [AuthenticationMiddleware(tokenManager: tokenManager, scopes: scopes)],
        )
    }

    public func gmail_users_drafts_create(
        to: [String],
        subject: String,
        body: String
    ) async throws -> Operations.Gmail_users_drafts_create.Output {
        let mime = buildMime(to: to, subject: subject, body: body)
        let base64UrlString = Data(mime.utf8).base64URLEncodedString()
        let draftJson = """
            {
                "message": {
                    "raw": "\(base64UrlString)"
                }
            }
        """
        let jsonData = Data(draftJson.utf8)
        return try await gmail_users_drafts_create(
            .init(
                path: .init(userId: "me"),
                body: .messageRfc822(.init(jsonData))
            )
        )

    }

    // IMPORTANT: CRLF (`\r\n`) + exactly one blank line before body.
    private func buildMime(to: [String], subject: String, body: String) -> String {
        let recipients = to.joined(separator: ", ")
        return "To: \(recipients)\r\n" +
               "Subject: \(subject)\r\n" +
               "MIME-Version: 1.0\r\n" +
               "Content-Type: text/plain; charset=UTF-8\r\n" +
               "\r\n" +
               "\(body)"
    }
}

extension Data {
    /// URL-safe Base64 (RFC 4648 §5): replace +/ with -_ and strip '=' padding & newlines
    func base64URLEncodedString() -> String {
        let b64 = self.base64EncodedString()
        return b64
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "\n", with: "")
    }
}
