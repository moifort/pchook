// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AudibleQuery: GraphQLQuery {
    static let operationName: String = "Audible"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Audible { audible { __typename sync { __typename status updatedAt libraryCount wishlistCount } import { __typename status importedCount totalCount delta current total message startedAt completedAt } } }"#
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
            .field("libraryCount", Int.self),
            .field("wishlistCount", Int.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            AudibleQuery.Data.Audible.Sync.self
          ] }

          /// Current sync status
          var status: PchookGraphQL.AudibleSyncStatus { __data["status"] }
          /// Last sync state update
          var updatedAt: PchookGraphQL.DateTime? { __data["updatedAt"] }
          /// Number of library items
          var libraryCount: Int { __data["libraryCount"] }
          /// Number of wishlist items
          var wishlistCount: Int { __data["wishlistCount"] }
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
            .field("importedCount", Int.self),
            .field("totalCount", Int.self),
            .field("delta", Int.self),
            .field("current", Int.self),
            .field("total", Int.self),
            .field("message", String.self),
            .field("startedAt", PchookGraphQL.DateTime?.self),
            .field("completedAt", PchookGraphQL.DateTime?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            AudibleQuery.Data.Audible.Import.self
          ] }

          /// Current import status
          var status: GraphQLEnum<PchookGraphQL.AudibleImportStatus> { __data["status"] }
          /// Number of books imported so far
          var importedCount: Int { __data["importedCount"] }
          /// Total number of library items
          var totalCount: Int { __data["totalCount"] }
          /// Items remaining to import
          var delta: Int { __data["delta"] }
          /// Number of items processed in current run
          var current: Int { __data["current"] }
          /// Total items to process in current run
          var total: Int { __data["total"] }
          /// Current progress message
          var message: String { __data["message"] }
          /// Import task start date
          var startedAt: PchookGraphQL.DateTime? { __data["startedAt"] }
          /// Import task completion date
          var completedAt: PchookGraphQL.DateTime? { __data["completedAt"] }
        }
      }
    }
  }

}