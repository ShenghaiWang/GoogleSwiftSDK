import Foundation
import OpenAPIRuntime
import OpenAPIAsyncHTTPClient
import GoogleAPITokenManager

public protocol AuthorizableClient {
    static nonisolated var oauthScopes: [String] { get }
    static nonisolated var redirectURI: String { get }
    static nonisolated func serverURL() throws -> URL
    static nonisolated var dateTranscoder: any DateTranscoder { get }

    init(serverURL: Foundation.URL, configuration: Configuration, transport: any ClientTransport, middlewares: [any ClientMiddleware])
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
    init(accountServiceFile: String, configuration: Configuration?, transportConfiguration: AsyncHTTPClientTransport.Configuration, scopes: [String]) throws
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

    init(clientId: String, clientSecret: String, redirectURI: String, configuration: Configuration?, transportConfiguration: AsyncHTTPClientTransport.Configuration, scopes: [String], tokenStorage: (any TokenStorage)?) throws

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
    init(tokenManager: GoogleOAuth2TokenManager, configuration: Configuration?, transportConfiguration: AsyncHTTPClientTransport.Configuration, scopes: [String], tokenStorage: (any TokenStorage)?) throws
}

extension AuthorizableClient {
    public static nonisolated var redirectURI: String {
        "http://localhost"
    }

    public static nonisolated var dateTranscoder: any DateTranscoder {
        .iso8601
    }

    public init(
        accountServiceFile: String,
        configuration: Configuration? = nil,
        transportConfiguration: AsyncHTTPClientTransport.Configuration = .init(),
        scopes: [String] = [],
    ) throws {
        let finalScopes = scopes.isEmpty ? Self.oauthScopes : scopes
        let tokenManager = try ServiceAccountTokenManager.loadFromFile(
            accountServiceFile,
            httpClient: URLSessionHTTPClient(),
            tokenStorage: nil,
            scopes: finalScopes
        )
        self.init(
            serverURL: try Self.serverURL(),
            configuration: configuration ?? .init(dateTranscoder: Self.dateTranscoder),
            transport: AsyncHTTPClientTransport(configuration: transportConfiguration),
            middlewares: [AuthenticationMiddleware(tokenManager: tokenManager, scopes: finalScopes)],
        )
    }

    public init(
        clientId: String,
        clientSecret: String,
        redirectURI: String = "http://localhost",
        configuration: Configuration? = nil,
        transportConfiguration: AsyncHTTPClientTransport.Configuration = .init(),
        scopes: [String] = [],
        tokenStorage: (any TokenStorage)? = InMemoeryTokenStorage()
    ) throws {
        let finalScopes = scopes.isEmpty ? Self.oauthScopes : scopes
        let tokenManager = GoogleOAuth2TokenManager(
            clientId: clientId,
            clientSecret: clientSecret,
            redirectURI: redirectURI,
            tokenStorage: tokenStorage,
            httpClient: URLSessionHTTPClient()
        )
        self.init(
            serverURL: try Self.serverURL(),
            configuration: configuration ?? .init(dateTranscoder: Self.dateTranscoder),
            transport: AsyncHTTPClientTransport(configuration: transportConfiguration),
            middlewares: [AuthenticationMiddleware(tokenManager: tokenManager, scopes: finalScopes)],
        )
    }

    public init(
        tokenManager: GoogleOAuth2TokenManager,
        configuration: Configuration? = nil,
        transportConfiguration: AsyncHTTPClientTransport.Configuration = .init(),
        scopes: [String] = [],
        tokenStorage: (any TokenStorage)? = InMemoeryTokenStorage()
    ) throws {
        let finalScopes = scopes.isEmpty ? Self.oauthScopes : scopes
        self.init(
            serverURL: try Self.serverURL(),
            configuration: configuration ?? .init(dateTranscoder: Self.dateTranscoder),
            transport: AsyncHTTPClientTransport(configuration: transportConfiguration),
            middlewares: [AuthenticationMiddleware(tokenManager: tokenManager, scopes: finalScopes)],
        )
    }
}

