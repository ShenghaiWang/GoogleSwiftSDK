import Foundation
import GoogleGmailSDK

enum GoogleGmail {
    static func run(with accountServiceFile: String) async throws {
        let googleGmailClient = try Client(accountServiceFile: accountServiceFile)

        do {
            // First, let's test basic authentication with user profile
            print("Testing user profile...")
            let profileResult = try await googleGmailClient.gmail_users_getProfile(
                .init(path: .init(userId: "me"))
            )
            print("Profile result: \(profileResult)")
            
            // Now try to create a draft
            print("Testing draft creation...")
            let result = try await googleGmailClient.gmail_users_drafts_create(
                to: ["tim.wang.au@gmail.com"],
                subject: "Sample Event",
                body: "This is a test event created via Swift SDK.",
            )
            print("Draft creation result: \(result)")
        } catch {
            print("Error: \(error)")
        }
    }

    static func run(withOAuthClientId clientId: String, clientSecret: String) async throws {
        let googleGmailClient = try Client(clientId: clientId,
                                           clientSecret: clientSecret)

        do {
            // Test the authenticated client
            print("📧 Testing Gmail API access...")

            let result = try await googleGmailClient.gmail_users_drafts_create(
                to: ["tim.wang.au@gmail.com"],
                subject: "Sample Event from OAuth",
                body: "This is a test event created via Swift SDK using OAuth 2.0!",
            )
            print("✅ Draft created successfully: \(result)")
        } catch {
            print("❌ Error: \(error)")
        }
    }
}
