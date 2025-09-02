import Foundation

// Featues that use service account
if let serviceAccountFile = ProcessInfo.processInfo.environment["GOOGLE_SERVICE_ACCOUNT_PATH"] {
//    try await GoogleSheets.run(with: serviceAccountFile)
//    try await GoogleSlides.run(with: serviceAccountFile)
//    try await GoogleDocs.run(with: serviceAccountFile)
    try await GoogleCalendar.run(with: serviceAccountFile)
}

// Features that use OAuth
if let clientId = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_ID"],
   let clientSecret = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_SECRET"] {
    print("🔐 Using OAuth 2.0 authentication for personal account")
    try await GoogleGmail.run(withOAuthClientId: clientId, clientSecret: clientSecret)
}
