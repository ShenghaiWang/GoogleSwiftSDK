import OpenAPIRuntime
import Foundation

extension OpenAPIRuntime.UndocumentedPayload {
    enum Error: Swift.Error, Equatable {
        case invalidResponse(String)
    }
    public func mapError(withErrorCode errorCode: Int) async throws -> Never {
        guard let body else {
            throw Error.invalidResponse("HTTP \(errorCode)")
        }
        let data = try await Data(collecting: body, upTo: 1024)
        let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
        throw Error.invalidResponse("HTTP \(errorCode): \(errorString)")
    }
}
