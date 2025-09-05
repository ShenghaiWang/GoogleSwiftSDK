import Common
import GoogleAPITokenManager
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime
import Foundation

extension Client: AuthorizableClient {
    public static nonisolated var oauthScopes: [String] {
        ["https://www.googleapis.com/auth/gmail.modify"]
    }

    public static nonisolated func serverURL() throws -> URL {
        try Servers.Server1.url()
    }

    /// Creates a new Gmail draft with the specified recipients, subject, and body.
    ///
    /// This method creates a draft email that can be sent later. The draft is created using the Gmail API
    /// and includes proper MIME formatting for the email content.
    ///
    /// - Parameters:
    ///   - to: An array of email addresses to send the draft to
    ///   - subject: The subject line of the email
    ///   - body: The plain text body content of the email
    /// - Returns: The API response containing the created draft information
    /// - Throws: An error if the draft creation fails or if the API request is unsuccessful
    public func gmail_users_drafts_create(
        to: [String],
        subject: String,
        body: String
    ) async throws -> Components.Schemas.Draft {
        let mime = buildMime(to: to, subject: subject, body: body)
        let base64UrlString = Data(mime.utf8).base64URLEncodedString()
        let draftJson = """
            {
                "message": {
                    "raw": "\(base64UrlString)"
                }
            }
        """
        let jsonData = Data(draftJson.utf8)
        let result = try await gmail_users_drafts_create(
            .init(
                path: .init(userId: "me"),
                body: .messageRfc822(.init(jsonData))
            )
        )
        return try await ResponseHandler.extractJSON(from: result)
    }

    // IMPORTANT: CRLF (`\r\n`) + exactly one blank line before body.
    private func buildMime(to: [String], subject: String, body: String) -> String {
        let recipients = to.joined(separator: ", ")
        return "To: \(recipients)\r\n" +
               "Subject: \(subject)\r\n" +
               "MIME-Version: 1.0\r\n" +
               "Content-Type: text/plain; charset=UTF-8\r\n" +
               "\r\n" +
               "\(body)"
    }
}

extension Data {
    /// URL-safe Base64 (RFC 4648 §5): replace +/ with -_ and strip '=' padding & newlines
    func base64URLEncodedString() -> String {
        let b64 = self.base64EncodedString()
        return b64
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "\n", with: "")
    }
}
