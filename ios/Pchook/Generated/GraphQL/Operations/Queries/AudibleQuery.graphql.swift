// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AudibleQuery: GraphQLQuery {
    static let operationName: String = "Audible"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Audible { audible { __typename sync { __typename status updatedAt library { __typename asin title authors narrators durationMinutes publisher language coverUrl finishedAt importedBookId series { __typename name position } } wishlist { __typename asin title authors importedBookId } } import { __typename status updatedAt taskId importedCount } } }"#
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
          .field("sync", Sync?.self),
          .field("import", Import?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AudibleQuery.Data.Audible.self
        ] }

        /// Synchronization state (null if never synced)
        var sync: Sync? { __data["sync"] }
        /// Import state (null if never imported)
        var `import`: Import? { __data["import"] }

        /// Audible.Sync
        ///
        /// Parent Type: `AudibleSync`
        struct Sync: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.AudibleSync }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("status", GraphQLEnum<PchookGraphQL.AudibleSyncStatus>.self),
            .field("updatedAt", PchookGraphQL.DateTime?.self),
            .field("library", [Library]?.self),
            .field("wishlist", [Wishlist]?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            AudibleQuery.Data.Audible.Sync.self
          ] }

          /// Current sync status
          var status: GraphQLEnum<PchookGraphQL.AudibleSyncStatus> { __data["status"] }
          /// Last sync state update
          var updatedAt: PchookGraphQL.DateTime? { __data["updatedAt"] }
          /// Library items (null if not yet fetched)
          var library: [Library]? { __data["library"] }
          /// Wishlist items (null if not yet fetched)
          var wishlist: [Wishlist]? { __data["wishlist"] }

          /// Audible.Sync.Library
          ///
          /// Parent Type: `AudibleItem`
          struct Library: PchookGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.AudibleItem }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("asin", String.self),
              .field("title", String.self),
              .field("authors", [String].self),
              .field("narrators", [String].self),
              .field("durationMinutes", Int.self),
              .field("publisher", String?.self),
              .field("language", String?.self),
              .field("coverUrl", String?.self),
              .field("finishedAt", PchookGraphQL.DateTime?.self),
              .field("importedBookId", PchookGraphQL.ID?.self),
              .field("series", Series?.self),
            ] }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              AudibleQuery.Data.Audible.Sync.Library.self
            ] }

            /// Amazon Standard Identification Number
            var asin: String { __data["asin"] }
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
            var coverUrl: String? { __data["coverUrl"] }
            /// Date the book was finished listening
            var finishedAt: PchookGraphQL.DateTime? { __data["finishedAt"] }
            /// ID of the imported book, if already imported
            var importedBookId: PchookGraphQL.ID? { __data["importedBookId"] }
            /// Series information
            var series: Series? { __data["series"] }

            /// Audible.Sync.Library.Series
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
                AudibleQuery.Data.Audible.Sync.Library.Series.self
              ] }

              /// Series name
              var name: String { __data["name"] }
              /// Position in the series
              var position: Int? { __data["position"] }
            }
          }

          /// Audible.Sync.Wishlist
          ///
          /// Parent Type: `AudibleItem`
          struct Wishlist: PchookGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.AudibleItem }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("asin", String.self),
              .field("title", String.self),
              .field("authors", [String].self),
              .field("importedBookId", PchookGraphQL.ID?.self),
            ] }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              AudibleQuery.Data.Audible.Sync.Wishlist.self
            ] }

            /// Amazon Standard Identification Number
            var asin: String { __data["asin"] }
            /// Book title
            var title: String { __data["title"] }
            /// Author names
            var authors: [String] { __data["authors"] }
            /// ID of the imported book, if already imported
            var importedBookId: PchookGraphQL.ID? { __data["importedBookId"] }
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
            .field("status", GraphQLEnum<PchookGraphQL.AudibleImportStatus>.self),
            .field("updatedAt", PchookGraphQL.DateTime?.self),
            .field("taskId", PchookGraphQL.ID?.self),
            .field("importedCount", Int.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            AudibleQuery.Data.Audible.Import.self
          ] }

          /// Current import status
          var status: GraphQLEnum<PchookGraphQL.AudibleImportStatus> { __data["status"] }
          /// Last import state update
          var updatedAt: PchookGraphQL.DateTime? { __data["updatedAt"] }
          /// Background task identifier
          var taskId: PchookGraphQL.ID? { __data["taskId"] }
          /// Number of books imported so far
          var importedCount: Int { __data["importedCount"] }
        }
      }
    }
  }

}