// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AudibleQuery: GraphQLQuery {
    static let operationName: String = "Audible"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Audible { audible { __typename sync { __typename status updatedAt entries { __typename asin title authors narrators durationMinutes publisher language coverUrl finishedAt seriesName seriesPosition source downloadedAt } } import { __typename status updatedAt taskId importedCount mappings { __typename asin bookId } } } }"#
      ))

    public init() {}

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("audible", Audible.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AudibleQuery.Data.self
      ] }

      /// Audible integration
      var audible: Audible { __data["audible"] }

      /// Audible
      ///
      /// Parent Type: `Audible`
      struct Audible: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Audible }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("sync", Sync.self),
          .field("import", Import.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AudibleQuery.Data.Audible.self
        ] }

        /// Synchronization state
        var sync: Sync { __data["sync"] }
        /// Import state
        var `import`: Import { __data["import"] }

        /// Audible.Sync
        ///
        /// Parent Type: `AudibleSync`
        struct Sync: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.AudibleSync }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("status", PchookGraphQL.AudibleSyncStatus.self),
            .field("updatedAt", PchookGraphQL.DateTime?.self),
            .field("entries", [Entry].self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            AudibleQuery.Data.Audible.Sync.self
          ] }

          /// Current sync status
          var status: PchookGraphQL.AudibleSyncStatus { __data["status"] }
          /// Last sync state update
          var updatedAt: PchookGraphQL.DateTime? { __data["updatedAt"] }
          /// Fetched Audible entries
          var entries: [Entry] { __data["entries"] }

          /// Audible.Sync.Entry
          ///
          /// Parent Type: `AudibleEntry`
          struct Entry: PchookGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.AudibleEntry }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("asin", PchookGraphQL.Asin.self),
              .field("title", String.self),
              .field("authors", [String].self),
              .field("narrators", [String].self),
              .field("durationMinutes", Int.self),
              .field("publisher", String?.self),
              .field("language", String?.self),
              .field("coverUrl", PchookGraphQL.Url?.self),
              .field("finishedAt", PchookGraphQL.DateTime?.self),
              .field("seriesName", String?.self),
              .field("seriesPosition", Int?.self),
              .field("source", PchookGraphQL.AudibleSource.self),
              .field("downloadedAt", PchookGraphQL.DateTime.self),
            ] }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              AudibleQuery.Data.Audible.Sync.Entry.self
            ] }

            /// Amazon Standard Identification Number
            var asin: PchookGraphQL.Asin { __data["asin"] }
            /// Book title
            var title: String { __data["title"] }
            /// Author names
            var authors: [String] { __data["authors"] }
            /// Narrator names
            var narrators: [String] { __data["narrators"] }
            /// Duration in minutes
            var durationMinutes: Int { __data["durationMinutes"] }
            /// Publisher name
            var publisher: String? { __data["publisher"] }
            /// Language
            var language: String? { __data["language"] }
            /// Cover image URL
            var coverUrl: PchookGraphQL.Url? { __data["coverUrl"] }
            /// Date the book was finished listening
            var finishedAt: PchookGraphQL.DateTime? { __data["finishedAt"] }
            /// Series name
            var seriesName: String? { __data["seriesName"] }
            /// Position in the series
            var seriesPosition: Int? { __data["seriesPosition"] }
            /// Item source
            var source: PchookGraphQL.AudibleSource { __data["source"] }
            /// Download timestamp
            var downloadedAt: PchookGraphQL.DateTime { __data["downloadedAt"] }
          }
        }

        /// Audible.Import
        ///
        /// Parent Type: `AudibleImport`
        struct Import: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.AudibleImport }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("status", PchookGraphQL.AudibleImportStatus.self),
            .field("updatedAt", PchookGraphQL.DateTime?.self),
            .field("taskId", PchookGraphQL.TaskId.self),
            .field("importedCount", Int.self),
            .field("mappings", [Mapping].self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            AudibleQuery.Data.Audible.Import.self
          ] }

          /// Current import status
          var status: PchookGraphQL.AudibleImportStatus { __data["status"] }
          /// Last import state update
          var updatedAt: PchookGraphQL.DateTime? { __data["updatedAt"] }
          /// Background task identifier
          var taskId: PchookGraphQL.TaskId { __data["taskId"] }
          /// Number of books imported so far
          var importedCount: Int { __data["importedCount"] }
          /// ASIN to book mappings
          var mappings: [Mapping] { __data["mappings"] }

          /// Audible.Import.Mapping
          ///
          /// Parent Type: `AsinBookMapping`
          struct Mapping: PchookGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.AsinBookMapping }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("asin", PchookGraphQL.Asin.self),
              .field("bookId", PchookGraphQL.BookId.self),
            ] }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              AudibleQuery.Data.Audible.Import.Mapping.self
            ] }

            /// Amazon Standard Identification Number
            var asin: PchookGraphQL.Asin { __data["asin"] }
            /// Imported book identifier
            var bookId: PchookGraphQL.BookId { __data["bookId"] }
          }
        }
      }
    }
  }

}