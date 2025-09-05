import Common
import GoogleAPITokenManager
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime
import Foundation

extension Client: AuthorizableClient {
    public static nonisolated var oauthScopes: [String] {
        ["https://www.googleapis.com/auth/drive"]
    }

    public static nonisolated func serverURL() throws -> URL {
        try Servers.Server1.url()
    }

    public func drive_files_list(query: String? = nil,
                                 pageSize: Int = 10,
                                 pageToken: String? = nil) async throws -> Components.Schemas.FileList {
        // Ensure pageSize is within allowed range (1-1000)
        let validPageSize = max(1, min(1000, pageSize))
        
        // Try without corpora parameter first - let the API use its default
        let input = Operations.Drive_files_list.Input.Query(
            pageSize: validPageSize,
            pageToken: pageToken,
            q: query
        )
        let result = try await drive_files_list(.init(query: input))
        return try await ResponseHandler.extractJSON(from: result)
    }
}
