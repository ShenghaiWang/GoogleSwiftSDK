import Foundation
import GoogleGmailSDK

enum GoogleGmail {
    static func run(with accountServiceFile: String) async throws {
        guard let calendarId = ProcessInfo.processInfo.environment["GOOGLE_CalendarId_ID"]
        else {
            print("❌ Error: GOOGLE_CalendarId_ID environment variable not set")
            print("💡 Set it with: export GOOGLE_CalendarId_ID=overocean@gmail.com")
            exit(1)
        }
        let googleGmailClient = try Client(accountServiceFile: accountServiceFile)

        do {
            let result = try await googleGmailClient.gmail_users_drafts_create(
                to: ["tim.wang.au@gmail.com"],
                subject: "Sample Event",
                body: "This is a test event created via Swift SDK.",
            )
            print(result)
        } catch {
            print(error)
        }
    }
}
