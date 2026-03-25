// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AudibleEntriesQuery: GraphQLQuery {
    static let operationName: String = "AudibleEntries"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query AudibleEntries { audible { __typename sync { __typename entries { __typename title authors language seriesName seriesPosition source } } } }"#
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
        AudibleEntriesQuery.Data.self
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
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AudibleEntriesQuery.Data.Audible.self
        ] }

        /// Synchronization state
        var sync: Sync { __data["sync"] }

        /// Audible.Sync
        ///
        /// Parent Type: `AudibleSync`
        struct Sync: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.AudibleSync }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("entries", [Entry].self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            AudibleEntriesQuery.Data.Audible.Sync.self
          ] }

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
              .field("title", String.self),
              .field("authors", [String].self),
              .field("language", String?.self),
              .field("seriesName", String?.self),
              .field("seriesPosition", PchookGraphQL.SeriesPosition?.self),
              .field("source", PchookGraphQL.AudibleSource.self),
            ] }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              AudibleEntriesQuery.Data.Audible.Sync.Entry.self
            ] }

            /// Book title
            var title: String { __data["title"] }
            /// Author names
            var authors: [String] { __data["authors"] }
            /// Language
            var language: String? { __data["language"] }
            /// Series name
            var seriesName: String? { __data["seriesName"] }
            /// Position in the series
            var seriesPosition: PchookGraphQL.SeriesPosition? { __data["seriesPosition"] }
            /// Item source
            var source: PchookGraphQL.AudibleSource { __data["source"] }
          }
        }
      }
    }
  }

}