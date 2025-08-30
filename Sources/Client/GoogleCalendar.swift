import Foundation
import GoogleCalendarSDK

enum GoogleCalendar {
    static func run(with accountServiceFile: String) async throws {
        guard let calendarId = ProcessInfo.processInfo.environment["GOOGLE_CalendarId_ID"]
        else {
            print("❌ Error: GOOGLE_CalendarId_ID environment variable not set")
            print("💡 Set it with: export GOOGLE_CalendarId_ID=overocean@gmail.com")
            exit(1)
        }
        let googleCalendarClient = try Client(accountServiceFile: accountServiceFile)

        do {
            let result = try await googleCalendarClient.calendar_events_insert(
                calendarId: calendarId,
                summary: "Sample Event",
                description: "This is a test event created via Swift SDK.",
                start: Date(),
                end: Date(timeIntervalSinceNow: 3600), // 1 hour later
                location: "Online",
                attendees: ["tim.wang.au@gmail.com"]
            )
            print(result)
        } catch {
            print(error)
        }
    }
}
