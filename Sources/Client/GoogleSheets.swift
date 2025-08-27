import Foundation
import GoogleSheetsSDK

enum GoogleSheets {
    static func run(with accountServiceFile: String) async throws {
        guard let spreadsheetId = ProcessInfo.processInfo.environment["GOOGLE_SPREADSHEET_ID"]
        else {
            print("❌ Error: GOOGLE_SPREADSHEET_ID environment variable not set")
            print("💡 Set it with: export GOOGLE_SPREADSHEET_ID=your_spreadsheet_id")
            exit(1)
        }
        let googleSheetsClient = try Client(accountServiceFile: accountServiceFile)

        do {
            let result = try await googleSheetsClient.sheets_spreadsheets_values_append(
                spreadsheetId: spreadsheetId,
                sheetName: "Sheet1",
                values: [
                    [
                        "Test Recipe", "test, ingredients, api",
                        "This is a test recipe added via API",
                    ]
                ]
            )
            print(result)
        } catch {
            print(error)
        }
    }
}
