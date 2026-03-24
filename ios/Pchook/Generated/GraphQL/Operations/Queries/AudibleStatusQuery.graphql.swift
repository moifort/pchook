// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AudibleStatusQuery: GraphQLQuery {
    static let operationName: String = "AudibleStatus"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query AudibleStatus { audibleSync { __typename connected fetchInProgress libraryCount wishlistCount lastSyncAt lastFetchedAt rawItemCount importTaskId } }"#
      ))

    public init() {}

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("audibleSync", AudibleSync.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AudibleStatusQuery.Data.self
      ] }

      /// Audible synchronization status
      var audibleSync: AudibleSync { __data["audibleSync"] }

      /// AudibleSync
      ///
      /// Parent Type: `AudibleSync`
      struct AudibleSync: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.AudibleSync }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("connected", Bool.self),
          .field("fetchInProgress", Bool.self),
          .field("libraryCount", Int.self),
          .field("wishlistCount", Int.self),
          .field("lastSyncAt", PchookGraphQL.DateTime?.self),
          .field("lastFetchedAt", PchookGraphQL.DateTime?.self),
          .field("rawItemCount", Int.self),
          .field("importTaskId", String.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AudibleStatusQuery.Data.AudibleSync.self
        ] }

        /// Credentials configured
        var connected: Bool { __data["connected"] }
        /// Fetch in progress
        var fetchInProgress: Bool { __data["fetchInProgress"] }
        /// Number of books in the library
        var libraryCount: Int { __data["libraryCount"] }
        /// Number of books in the wishlist
        var wishlistCount: Int { __data["wishlistCount"] }
        /// Last sync date
        var lastSyncAt: PchookGraphQL.DateTime? { __data["lastSyncAt"] }
        /// Last fetch date
        var lastFetchedAt: PchookGraphQL.DateTime? { __data["lastFetchedAt"] }
        /// Number of raw items
        var rawItemCount: Int { __data["rawItemCount"] }
        /// Identifier of the Audible import task (use task query to get state)
        var importTaskId: String { __data["importTaskId"] }
      }
    }
  }

}