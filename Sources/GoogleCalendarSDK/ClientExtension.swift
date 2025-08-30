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
        scopes: [String] = ["https://www.googleapis.com/auth/calendar"],
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

    public func calendar_events_insert(
        calendarId: String,
        summary: String,
        description: String?,
        start: Date,
        end: Date,
        location: String?,
        attendees: [String],
        sendUpdates: String? = nil
    ) async throws -> Operations.Calendar_events_insert.Output {
        try await calendar_events_insert(
            path: .init(calendarId: calendarId),
            query: .init(sendUpdates: .all),
            body: .json(
                .init(
                    // If adding attendees, need to set up domain-wide delegation for a service account
                    // https://developers.google.com/workspace/guides/create-credentials
                    // attendees: attendees.map { .init(email: $0) },
                    description: description,
                    end: .init(dateTime: end),
                    location: location,
                    start: .init(dateTime: start),
                    summary: summary
                )
            )
        )
    }
}
