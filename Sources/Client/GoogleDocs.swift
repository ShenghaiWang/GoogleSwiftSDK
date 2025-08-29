import Foundation
import GoogleDocsSDK

enum GoogleDocs {
    static func run(with accountServiceFile: String) async throws {
        guard let documentId = ProcessInfo.processInfo.environment["GOOGLE_DOCUMENT_ID"] else {
            print("❌ Error: GOOGLE_DOCUMENT_ID environment variable not set")
            print("💡 Set it with: export GOOGLE_DOCUMENT_ID=your_document_id")
            exit(1)
        }
        let googleDocsClient = try Client(accountServiceFile: accountServiceFile)

        let insertTextRequest = Components.Schemas.Request(
            insertText:
                    .init(
                        endOfSegmentLocation: .init(segmentId: nil), // Insert at the end of the document
                        location: nil,
                        text: "\nText from API 2\n"
                    )
        )

        let insertInlineImageRequest = Components.Schemas.Request(
            insertInlineImage:
                    .init(
                        endOfSegmentLocation: .init(segmentId: nil),
                        location: nil,
                        uri: "https://deepresearch.timwang.au/results/F3275E05-7864-4115-AA82-060A393D437F.png"
            )
        )

//        public var insertPageBreak: Components.Schemas.InsertPageBreakRequest?
//        /// - Remark: Generated from `#/components/schemas/Request/insertSectionBreak`.
//        public var insertSectionBreak: Components.Schemas.InsertSectionBreakRequest?
//        /// - Remark: Generated from `#/components/schemas/Request/insertTable`.
//        public var insertTable: Components.Schemas.InsertTableRequest?
//        /// - Remark: Generated from `#/components/schemas/Request/insertTableColumn`.
//        public var insertTableColumn: Components.Schemas.InsertTableColumnRequest?
//        /// - Remark: Generated from `#/components/schemas/Request/insertTableRow`.
//        public var insertTableRow: Components.Schemas.InsertTableRowRequest?
//        /// - Remark: Generated from `#/components/schemas/Request/insertText`.
//        public var insertText: Components.Schemas.InsertTextRequest?

//        updateDocumentStyle: Components.Schemas.UpdateDocumentStyleRequest? = nil,
//        updateParagraphStyle: Components.Schemas.UpdateParagraphStyleRequest? = nil,
//        updateSectionStyle: Components.Schemas.UpdateSectionStyleRequest? = nil,
//        updateTableCellStyle: Components.Schemas.UpdateTableCellStyleRequest? = nil,
//        updateTableColumnProperties: Components.Schemas.UpdateTableColumnPropertiesRequest? = nil,
//        updateTableRowStyle: Components.Schemas.UpdateTableRowStyleRequest? = nil,

        let requests: [Components.Schemas.Request] = [
            insertTextRequest,
//            updateTextStyle,
//            insertInlineImageRequest,
        ]

        do {
            let result = try await googleDocsClient.docs_documents_batchUpdate(
                documentId: documentId,
                requests: requests
            )
            print(result)
            let doc = try await googleDocsClient.docs_documents_get(documentId: documentId)
            print(doc)

            let updateTextStyle = Components.Schemas.Request(
                updateTextStyle: .init(
                    fields: "*",
                    range: .init(endIndex: doc.body?.content?.last?.endIndex ?? 0, startIndex: doc.body?.content?.last?.startIndex ?? 0),
                    textStyle: .init(
                        bold: true,
                        )
                    )
                )
            let updatedResult = try await googleDocsClient.docs_documents_batchUpdate(
                documentId: documentId,
                requests: [updateTextStyle],
            )
            print(updatedResult)
        } catch {
            print(error)
        }
    }
}
