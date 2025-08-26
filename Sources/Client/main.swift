import Foundation
import Common
import GoogleAPITokenManager
import OpenAPIAsyncHTTPClient
import GoogleSheetsSDK

guard let serviceAccountPath = ProcessInfo.processInfo.environment["GOOGLE_SERVICE_ACCOUNT_PATH"] else {
    print("❌ Error: GOOGLE_SERVICE_ACCOUNT_PATH environment variable not set")
    print("💡 Set it with: export GOOGLE_SERVICE_ACCOUNT_PATH=/path/to/your/service-account.json")
    exit(1)
}

guard let spreadsheetId = ProcessInfo.processInfo.environment["GOOGLE_SPREADSHEET_ID"] else {
    print("❌ Error: GOOGLE_SPREADSHEET_ID environment variable not set")
    print("💡 Set it with: export GOOGLE_SPREADSHEET_ID=your_spreadsheet_id")
    exit(1)
}


let googleSheetsClient = try Client(accountServiceFile: serviceAccountPath)

do {
    let result = try await googleSheetsClient.sheets_spreadsheets_values_append(
        spreadsheetId: spreadsheetId,
        sheetName: "Sheet1",
        values: [["Test Recipe", "test, ingredients, api", "This is a test recipe added via API"]]
    )
    print(result)
} catch {
    print(error)
}
