// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoogleSwiftSDK",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .visionOS(.v1),
    ],
    products: [
        .library(name: "GoogleSheetsSDK", targets: ["GoogleSheetsSDK"]),
        .library(name: "GoogleSlidesSDK", targets: ["GoogleSlidesSDK"]),
        .library(name: "GoogleDocsSDK", targets: ["GoogleDocsSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.10.2"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.8.2"),
        .package(
            url: "https://github.com/swift-server/swift-openapi-async-http-client", from: "1.1.0"),
        .package(url: "https://github.com/ShenghaiWang/GoogleAPITokenManager.git", from: "0.1.0"),
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
    ]
)
