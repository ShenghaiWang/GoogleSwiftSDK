// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoogleSwiftSDK",
    platforms: [
        .macOS("13.0"),
        .macCatalyst("16.0"),
        .iOS("16.0"),
        .watchOS("9.0"),
        .tvOS("16.0"),
        .visionOS("1.0"),
    ],
    products: [
        .library(name: "GoogleSheetsSDK", targets: ["GoogleSheetsSDK"]),
        .library(name: "GoogleSlidesSDK", targets: ["GoogleSlidesSDK"]),
        .library(name: "GoogleDocsSDK", targets: ["GoogleDocsSDK"]),
        .library(name: "GoogleCalendarSDK", targets: ["GoogleCalendarSDK"]),
        .library(name: "GoogleGmailSDK", targets: ["GoogleGmailSDK"]),
        .library(name: "GoogleDriveSDK", targets: ["GoogleDriveSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.10.2"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.8.2"),
        .package(
            url: "https://github.com/swift-server/swift-openapi-async-http-client", from: "1.1.0"),
        .package(url: "https://github.com/ShenghaiWang/GoogleAPITokenManager.git", from: "1.0.2"),
    ],
    targets: [
        .target(
            name: "Common",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(
                    name: "OpenAPIAsyncHTTPClient", package: "swift-openapi-async-http-client"),
                .product(name: "GoogleAPITokenManager", package: "GoogleAPITokenManager"),
            ]
        ),
        .executableTarget(
            name: "Client",
            dependencies: [
                "Common",
                "GoogleSheetsSDK",
                "GoogleSlidesSDK",
                "GoogleDocsSDK",
                "GoogleCalendarSDK",
                "GoogleGmailSDK",
                "GoogleDriveSDK",
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(
                    name: "OpenAPIAsyncHTTPClient", package: "swift-openapi-async-http-client"),
                .product(name: "GoogleAPITokenManager", package: "GoogleAPITokenManager"),
            ],
            plugins: [
//                                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
            ]
        ),
        .target(
            name: "GoogleSheetsSDK",
            dependencies: [
                "Common",
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(
                    name: "OpenAPIAsyncHTTPClient", package: "swift-openapi-async-http-client"),
                .product(name: "GoogleAPITokenManager", package: "GoogleAPITokenManager"),
            ]
        ),
        .target(
            name: "GoogleSlidesSDK",
            dependencies: [
                "Common",
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(
                    name: "OpenAPIAsyncHTTPClient", package: "swift-openapi-async-http-client"),
                .product(name: "GoogleAPITokenManager", package: "GoogleAPITokenManager"),
            ]
        ),
        .target(
            name: "GoogleDocsSDK",
            dependencies: [
                "Common",
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(
                    name: "OpenAPIAsyncHTTPClient", package: "swift-openapi-async-http-client"),
                .product(name: "GoogleAPITokenManager", package: "GoogleAPITokenManager"),
            ]
        ),
        .target(
            name: "GoogleCalendarSDK",
            dependencies: [
                "Common",
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(
                    name: "OpenAPIAsyncHTTPClient", package: "swift-openapi-async-http-client"),
                .product(name: "GoogleAPITokenManager", package: "GoogleAPITokenManager"),
            ]
        ),
        .target(
            name: "GoogleGmailSDK",
            dependencies: [
                "Common",
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(
                    name: "OpenAPIAsyncHTTPClient", package: "swift-openapi-async-http-client"),
                .product(name: "GoogleAPITokenManager", package: "GoogleAPITokenManager"),
            ]
        ),
        .target(
            name: "GoogleDriveSDK",
            dependencies: [
                "Common",
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(
                    name: "OpenAPIAsyncHTTPClient", package: "swift-openapi-async-http-client"),
                .product(name: "GoogleAPITokenManager", package: "GoogleAPITokenManager"),
            ]
        ),
    ]
)
