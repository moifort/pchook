// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AudibleQuery: GraphQLQuery {
    static let operationName: String = "Audible"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Audible { audible { __typename sync { __typename syncStatus syncUpdatedAt entries { __typename item { __typename asin title authors narrators durationMinutes publisher language coverUrl finishedAt series { __typename name position } } source downloadedAt } } import { __typename importStatus importUpdatedAt taskId importedCount mappings { __typename asin bookId } } } }"#
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
            .field("syncStatus", PchookGraphQL.AudibleSyncStatus.self),
            .field("syncUpdatedAt", PchookGraphQL.DateTime?.self),
            .field("entries", [Entry].self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            AudibleQuery.Data.Audible.Sync.self
          ] }

          /// Current sync status
          var syncStatus: PchookGraphQL.AudibleSyncStatus { __data["syncStatus"] }
          /// Last sync state update
          var syncUpdatedAt: PchookGraphQL.DateTime? { __data["syncUpdatedAt"] }
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
              .field("item", Item.self),
              .field("source", PchookGraphQL.AudibleSource.self),
              .field("downloadedAt", PchookGraphQL.DateTime.self),
            ] }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              AudibleQuery.Data.Audible.Sync.Entry.self
            ] }

            /// Audible item data
            var item: Item { __data["item"] }
            /// Item source
            var source: PchookGraphQL.AudibleSource { __data["source"] }
            /// Download timestamp
            var downloadedAt: PchookGraphQL.DateTime { __data["downloadedAt"] }

            /// Audible.Sync.Entry.Item
            ///
            /// Parent Type: `AudibleItem`
            struct Item: PchookGraphQL.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.AudibleItem }
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
                .field("series", Series?.self),
              ] }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                AudibleQuery.Data.Audible.Sync.Entry.Item.self
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
              /// Series information
              var series: Series? { __data["series"] }

              /// Audible.Sync.Entry.Item.Series
              ///
              /// Parent Type: `AudibleSeriesInfo`
              struct Series: PchookGraphQL.SelectionSet {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.AudibleSeriesInfo }
                static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("name", String.self),
                  .field("position", Int?.self),
                ] }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                  AudibleQuery.Data.Audible.Sync.Entry.Item.Series.self
                ] }

                /// Series name
                var name: String { __data["name"] }
                /// Position in the series
                var position: Int? { __data["position"] }
              }
            }
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
            .field("importStatus", PchookGraphQL.AudibleImportStatus.self),
            .field("importUpdatedAt", PchookGraphQL.DateTime?.self),
            .field("taskId", PchookGraphQL.TaskId.self),
            .field("importedCount", Int.self),
            .field("mappings", [Mapping].self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            AudibleQuery.Data.Audible.Import.self
          ] }

          /// Current import status
          var importStatus: PchookGraphQL.AudibleImportStatus { __data["importStatus"] }
          /// Last import state update
          var importUpdatedAt: PchookGraphQL.DateTime? { __data["importUpdatedAt"] }
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