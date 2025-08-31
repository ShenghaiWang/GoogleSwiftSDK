import Common
import GoogleAPITokenManager
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime
import Foundation

extension Client {
    enum Error: Swift.Error {
        case invalidResponse(statusCode: Int)
    }
    /// Initializes a Google Calendar client using Service Account authentication for server-to-server communication.
    ///
    /// This initializer is designed for server applications that need to access Google Calendar on behalf of users
    /// without requiring user interaction. It uses a service account JSON file for authentication.
    ///
    /// - Parameters:
    ///   - accountServiceFile: The path to the service account JSON file containing credentials
    ///   - configuration: The client configuration settings. Defaults to a new Configuration instance
    ///   - transportConfiguration: The HTTP transport configuration. Defaults to a new AsyncHTTPClientTransport.Configuration
    ///   - scopes: The OAuth 2.0 scopes to request. Defaults to Google Calendar read/write permissions
    /// - Throws: An error if the service account file cannot be loaded or if initialization fails
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
            middlewares: [AuthenticationMiddleware(tokenManager: tokenManager, scopes: scopes)],
        )
    }

    /// Creates a new event in the specified Google Calendar.
    ///
    /// This method creates a calendar event with the provided details. The event will be inserted
    /// into the specified calendar and notifications will be sent to all attendees by default.
    /// Note that adding attendees requires domain-wide delegation setup for service accounts.
    ///
    /// - Parameters:
    ///   - calendarId: The unique identifier of the calendar to insert the event into
    ///   - summary: The title/summary of the event
    ///   - description: Optional detailed description of the event
    ///   - start: The start date and time of the event
    ///   - end: The end date and time of the event
    ///   - location: Optional location where the event takes place
    ///   - attendees: Array of email addresses for event attendees (requires domain-wide delegation)
    ///   - sendUpdates: Optional parameter to control notification sending. Defaults to sending to all attendees
    /// - Returns: The API response containing the created event information
    /// - Throws: An error if the event creation fails or if the API request is unsuccessful
    /// - Note: To add attendees with service accounts, domain-wide delegation must be configured. See: https://developers.google.com/workspace/guides/create-credentials
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
