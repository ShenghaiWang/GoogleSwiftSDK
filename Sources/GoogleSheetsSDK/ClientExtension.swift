import Common
import GoogleAPITokenManager
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime

extension Client {
    /// Initializes a Google Sheets client using Service Account authentication for server-to-server communication.
    ///
    /// This initializer is designed for server applications that need to access Google Sheets on behalf of users
    /// without requiring user interaction. It uses a service account JSON file for authentication.
    ///
    /// - Parameters:
    ///   - accountServiceFile: The path to the service account JSON file containing credentials
    ///   - configuration: The client configuration settings. Defaults to a new Configuration instance
    ///   - transportConfiguration: The HTTP transport configuration. Defaults to a new AsyncHTTPClientTransport.Configuration
    ///   - scopes: The OAuth 2.0 scopes to request. Defaults to Google Sheets read/write permissions
    /// - Throws: An error if the service account file cannot be loaded or if initialization fails
    public init(
        accountServiceFile: String,
        configuration: Configuration = .init(),
        transportConfiguration: AsyncHTTPClientTransport.Configuration = .init(),
        scopes: [String] = ["https://www.googleapis.com/auth/spreadsheets"],
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

    /// Appends values to a Google Sheets spreadsheet.
    ///
    /// This method adds new rows of data to the end of the specified sheet. The values are inserted
    /// after the last row that contains data in the sheet. The input option is set to "userEntered"
    /// which means the values will be parsed as if the user typed them into the UI.
    ///
    /// - Parameters:
    ///   - spreadsheetId: The unique identifier of the Google Sheets spreadsheet
    ///   - sheetName: The name of the sheet within the spreadsheet to append data to
    ///   - range: Optional specific range to append to. If nil, data is appended after the last row
    ///   - values: A 2D array of values to append, where each inner array represents a row
    /// - Returns: The API response containing information about the append operation
    /// - Throws: An error if the append operation fails or if the API request is unsuccessful
    public func sheets_spreadsheets_values_append(
        spreadsheetId: String,
        sheetName: String,
        range: String? = nil,
        values: [[OpenAPIRuntime.OpenAPIValueContainer]],
    ) async throws -> Operations.Sheets_spreadsheets_values_append.Output {
        try await sheets_spreadsheets_values_append(
            .init(
                path: .init(
                    spreadsheetId: spreadsheetId,
                    range: sheetName),
                query: .init(
                    valueInputOption: Operations.Sheets_spreadsheets_values_append.Input.Query
                        .ValueInputOptionPayload.userEntered),
                body: .json(
                    .init(
                        majorDimension: .rows,
                        range: range,
                        values: values,
                    )
                )
            )
        )
    }
}
