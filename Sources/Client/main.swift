import Foundation

guard let serviceAccountFile = ProcessInfo.processInfo.environment["GOOGLE_SERVICE_ACCOUNT_PATH"]
else {
    print("❌ Error: GOOGLE_SERVICE_ACCOUNT_PATH environment variable not set")
    print("💡 Set it with: export GOOGLE_SERVICE_ACCOUNT_PATH=/path/to/your/service-account.json")
    exit(1)
}

//try await GoogleSheets.run(with: serviceAccountFile)

//try await GoogleSlides.run(with: serviceAccountFile)

//try await GoogleDocs.run(with: serviceAccountFile)

//try await GoogleCalendar.run(with: serviceAccountFile)

try await GoogleGmail.run(with: serviceAccountFile)
