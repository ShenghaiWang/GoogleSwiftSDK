import GoogleAPITokenManager
import OpenAPIRuntime
import OpenAPIAsyncHTTPClient
import Common

extension Client {
    public init(accountServiceFile: String,
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
            middlewares: [AuthenticationMiddleware(tokenManager: tokenManager)],
        )
    }

    public func sheets_spreadsheets_values_append(
        spreadsheetId: String,
        sheetName: String,
        range: String? = nil,
        values: [[OpenAPIRuntime.OpenAPIValueContainer]],
    ) async throws -> Operations.Sheets_spreadsheets_values_append.Output {
        try await sheets_spreadsheets_values_append(
            .init(path: .init(spreadsheetId: spreadsheetId,
                              range: sheetName),
                  query: .init(valueInputOption: Operations.Sheets_spreadsheets_values_append.Input.Query.ValueInputOptionPayload.userEntered),
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
