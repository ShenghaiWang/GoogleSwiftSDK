import OpenAPIRuntime
import Foundation

/// Generic response handling utilities to eliminate repetitive switch/case patterns
public enum ResponseHandler {
    
    /// Handles any OpenAPI operation result by extracting JSON from .ok cases and handling errors
    /// This eliminates the entire switch statement pattern
    public static func extractJSON<Result, JSON>(
        from result: Result
    ) async throws -> JSON {
        let mirror = Mirror(reflecting: result)
        
        // Look for the .ok case
        for child in mirror.children {
            if child.label == "ok" {
                // Extract JSON from the .ok case
                return try await extractJSONFromOKValue(child.value)
            } else if child.label == "undocumented" {
                // Handle error case
                try await handleUndocumentedError(child.value)
            }
        }
        
        throw ResponseError.unexpectedResponseFormat
    }
    
    /// Extracts JSON from an .ok response value by handling the .body.json pattern
    /// This eliminates the `switch value.body { case let .json(response): response }` pattern
    private static func extractJSONFromOKValue<JSON>(_ okValue: Any) async throws -> JSON {
        let okMirror = Mirror(reflecting: okValue)
        
        // Look for the body property
        guard let bodyChild = okMirror.children.first(where: { $0.label == "body" }) else {
            throw ResponseError.missingBody
        }
        
        // Handle the body enum to extract JSON
        let bodyMirror = Mirror(reflecting: bodyChild.value)
        
        // Look for the .json case in the body enum
        for bodyCase in bodyMirror.children {
            if bodyCase.label == "json" {
                guard let jsonValue = bodyCase.value as? JSON else {
                    throw ResponseError.invalidJSONType
                }
                return jsonValue
            }
        }
        
        throw ResponseError.jsonCaseNotFound
    }
    
    /// Handles undocumented error responses
    private static func handleUndocumentedError(_ undocumentedValue: Any) async throws -> Never {
        let undocumentedMirror = Mirror(reflecting: undocumentedValue)
        
        var statusCode: Int = 0
        var payload: OpenAPIRuntime.UndocumentedPayload?
        
        for child in undocumentedMirror.children {
            if child.label == "statusCode" {
                statusCode = child.value as! Int
            } else if child.label == "payload" {
                payload = child.value as? OpenAPIRuntime.UndocumentedPayload
            }
        }
        
        if let payload = payload {
            try await payload.mapError(withErrorCode: statusCode)
        } else {
            throw ResponseError.unknownError(statusCode)
        }
    }
}

public enum ResponseError: Error, Equatable {
    case unexpectedResponseFormat
    case missingBody
    case invalidJSONType
    case jsonCaseNotFound
    case unknownError(Int)
}