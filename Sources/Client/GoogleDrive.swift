import Foundation
import GoogleDriveSDK

enum GoogleDrive {
    static func run(with accountServiceFile: String) async throws {
        let googleDriveClient = try Client(accountServiceFile: accountServiceFile)
        // List all files (no query) or use a proper search query like "name contains 'test'"
        let fileList = try await googleDriveClient.drive_files_list()
        print("Found \(fileList.files?.count ?? 0) files")
        
        // Print first few file names if any exist
        if let files = fileList.files, !files.isEmpty {
            print("Files:")
            for file in files.prefix(5) {
                print("- \(file.name ?? "Unnamed")")
            }
        }
    }

    static func run(withOAuthClientId clientId: String, clientSecret: String) async throws {
        let googleDriveClient = try Client(clientId: clientId,
                                           clientSecret: clientSecret)

        // List all files (no query) or use a proper search query like "name contains 'test'"
        let fileList = try await googleDriveClient.drive_files_list()
        print("Found \(fileList.files?.count ?? 0) files")
        
        // Print first few file names if any exist
        if let files = fileList.files, !files.isEmpty {
            print("Files:")
            for file in files.prefix(5) {
                print("- \(file.name ?? "Unnamed")")
            }
        }
    }
}
