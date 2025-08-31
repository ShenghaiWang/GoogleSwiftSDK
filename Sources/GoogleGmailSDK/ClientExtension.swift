import Common
import GoogleAPITokenManager
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime
import Foundation

extension Client {
    enum Error: Swift.Error {
        case invalidResponse(statusCode: Int)
    }
    
    /// Initializes a Gmail client using Service Account authentication for server-to-server communication.
    ///
    /// This initializer is designed for server applications that need to access Gmail on behalf of users
    /// without requiring user interaction. It uses a service account JSON file for authentication.
    ///
    /// - Parameters:
    ///   - accountServiceFile: The path to the service account JSON file containing credentials
    ///   - configuration: The client configuration settings. Defaults to a new Configuration instance
    ///   - transportConfiguration: The HTTP transport configuration. Defaults to a new AsyncHTTPClientTransport.Configuration
    ///   - scopes: The OAuth 2.0 scopes to request. Defaults to Gmail modify permissions
    /// - Throws: An error if the service account file cannot be loaded or if initialization fails
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
    
    /// Initializes a Gmail client using OAuth 2.0 authentication with client credentials.
    ///
    /// This initializer is suitable for applications that need to authenticate users through the OAuth 2.0 flow.
    /// It creates a token manager with the provided client credentials and handles token storage.
    ///
    /// - Parameters:
    ///   - clientId: The OAuth 2.0 client ID from Google Cloud Console
    ///   - clientSecret: The OAuth 2.0 client secret from Google Cloud Console
    ///   - redirectURI: The redirect URI for OAuth flow. Defaults to "http://localhost"
    ///   - configuration: The client configuration settings. Defaults to a new Configuration instance
    ///   - transportConfiguration: The HTTP transport configuration. Defaults to a new AsyncHTTPClientTransport.Configuration
    ///   - scopes: The OAuth 2.0 scopes to request. Defaults to Gmail modify permissions
    ///   - tokenStorage: The token storage implementation. Defaults to in-memory storage
    /// - Throws: An error if initialization fails or if the server URL cannot be constructed
    public init(
        clientId: String,
        clientSecret: String,
        redirectURI: String = "http://localhost",
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

    /// Initializes a Gmail client using an existing OAuth 2.0 token manager.
    ///
    /// This initializer allows you to provide a pre-configured token manager, which is useful
    /// when you need more control over the authentication process or when reusing an existing token manager.
    ///
    /// - Parameters:
    ///   - tokenManager: A pre-configured GoogleOAuth2TokenManager instance
    ///   - configuration: The client configuration settings. Defaults to a new Configuration instance
    ///   - transportConfiguration: The HTTP transport configuration. Defaults to a new AsyncHTTPClientTransport.Configuration
    ///   - scopes: The OAuth 2.0 scopes to request. Defaults to Gmail modify permissions
    ///   - tokenStorage: The token storage implementation. Defaults to in-memory storage
    /// - Throws: An error if initialization fails or if the server URL cannot be constructed
    public init(
        tokenManager: GoogleOAuth2TokenManager,
        configuration: Configuration = .init(),
        transportConfiguration: AsyncHTTPClientTransport.Configuration = .init(),
        scopes: [String] = ["https://www.googleapis.com/auth/gmail.modify"],
        tokenStorage: (any TokenStorage)? = InMemoeryTokenStorage()
    ) throws {
        self.init(
            serverURL: try Servers.Server1.url(),
            configuration: configuration,
            transport: AsyncHTTPClientTransport(configuration: transportConfiguration),
            middlewares: [AuthenticationMiddleware(tokenManager: tokenManager, scopes: scopes)],
        )
    }

    /// Creates a new Gmail draft with the specified recipients, subject, and body.
    ///
    /// This method creates a draft email that can be sent later. The draft is created using the Gmail API
    /// and includes proper MIME formatting for the email content.
    ///
    /// - Parameters:
    ///   - to: An array of email addresses to send the draft to
    ///   - subject: The subject line of the email
    ///   - body: The plain text body content of the email
    /// - Returns: The API response containing the created draft information
    /// - Throws: An error if the draft creation fails or if the API request is unsuccessful
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
