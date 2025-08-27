import Foundation
import GoogleSlidesSDK

enum GoogleSlides {
    static func run(with accountServiceFile: String) async throws {
        guard let PresentationId = ProcessInfo.processInfo.environment["GOOGLE_SLIDES_ID"] else {
            print("❌ Error: GOOGLE_SPREADSHEET_ID environment variable not set")
            print("💡 Set it with: export GOOGLE_SPREADSHEET_ID=your_spreadsheet_id")
            exit(1)
        }
        let googleSlidesClient = try Client(accountServiceFile: accountServiceFile)

        let slideId = "MyNewSlide_\(UUID().uuidString.prefix(8))"
        let shapeId = "MyTextBox_\(UUID().uuidString.prefix(8))"
        let imageId = "MyImage_\(UUID().uuidString.prefix(8))"

        let createSlideRequest = Components.Schemas.Request(
            createSlide:
                .init(
                    objectId: String(slideId),
                    slideLayoutReference: .init(predefinedLayout: .blank)
                )
        )

        let createShapeRequest = Components.Schemas.Request(
            createShape:
                .init(
                    elementProperties: .init(
                        pageObjectId: String(slideId),
                        size: .init(
                            height: .init(magnitude: 100, unit: .pt),
                            width: .init(magnitude: 300, unit: .pt)
                        ),
                        transform: .init(
                            scaleX: 1, scaleY: 1,
                            translateX: 100, translateY: 100,
                            unit: .pt
                        )
                    ),
                    objectId: String(shapeId),
                    shapeType: .textBox,
                )
        )

        let insertTextRequest = Components.Schemas.Request(
            insertText:
                .init(
                    insertionIndex: 0,
                    objectId: String(shapeId),
                    text: "Hello from API!"
                )
        )

        let insertImageRequest = Components.Schemas.Request(
            createImage:
                .init(
                    elementProperties: .init(
                        pageObjectId: String(slideId),
                        size: .init(
                            height: .init(magnitude: 100, unit: .pt),
                            width: .init(magnitude: 300, unit: .pt)
                        ),
                        transform: .init(
                            scaleX: 1, scaleY: 1,
                            translateX: 100, translateY: 100,
                            unit: .pt
                        )
                    ),
                    objectId: imageId,
                    url:
                        "https://deepresearch.timwang.au/results/F3275E05-7864-4115-AA82-060A393D437F.png"
                )
        )

        let requests: [Components.Schemas.Request] = [
            createSlideRequest,
            createShapeRequest,
            insertTextRequest,
            insertImageRequest,
        ]

        do {
            let result = try await googleSlidesClient.slides_presentations_batchUpdate(
                presentationId: PresentationId,
                requests: requests
            )
            print(result)
        } catch {
            print(error)
        }
    }
}
