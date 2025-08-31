import Common
import GoogleAPITokenManager
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime
import Foundation

extension Client: AuthorizableClient {
    public static var oauthScopes: [String] {
        ["https://www.googleapis.com/auth/spreadsheets"]
    }

    public static func serverURL() throws -> URL {
        try Servers.Server1.url()
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
